using FluentAssertions;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.DTOs.JobApplication.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using Moq;
using Xunit;

namespace JobWay.UnitTests.Services;

public class InvitationServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<ICompanyProfileRepository> _companyRepositoryMock = new();
    private readonly Mock<ICandidateProfileRepository> _candidateRepositoryMock = new();
    private readonly Mock<IVacancyRepository> _vacancyRepositoryMock = new();
    private readonly Mock<IJobApplicationRepository> _applicationRepositoryMock = new();
    private readonly Mock<IInvitationRepository> _invitationRepositoryMock = new();
    private readonly Mock<INotificationService> _notificationServiceMock = new();
    private readonly Mock<IJobApplicationService> _jobApplicationServiceMock = new();
    private readonly Mock<ICacheService> _cacheServiceMock = new();

    private readonly InvitationService _sut;

    public InvitationServiceTests()
    {
        _unitOfWorkMock.Setup(u => u.CompanyProfiles).Returns(_companyRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.CandidateProfiles).Returns(_candidateRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Vacancies).Returns(_vacancyRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.JobApplications).Returns(_applicationRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Invitations).Returns(_invitationRepositoryMock.Object);

        _sut = new InvitationService(
            _unitOfWorkMock.Object,
            _notificationServiceMock.Object,
            _jobApplicationServiceMock.Object,
            _cacheServiceMock.Object);
    }

    private static CandidateProfile MakeCandidate(bool visible = true) => new()
    {
        Id = Guid.NewGuid(),
        UserId = Guid.NewGuid(),
        FullName = "Candidate Name",
        IsVisibleToEmployers = visible,
        Skills = [],
        User = new User { Email = "candidate@test.com", PasswordHash = "hash", IsActive = true }
    };

    // Готовит компанию, активную вакансию и открытого кандидата: все проверки проходят
    private (CompanyProfile Company, Vacancy Vacancy, CandidateProfile Candidate) ArrangeHappyPath()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();

        _companyRepositoryMock
            .Setup(r => r.GetByUserIdAsync(company.UserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(company);
        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);
        _candidateRepositoryMock
            .Setup(r => r.GetByIdAsync(candidate.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(candidate);

        return (company, vacancy, candidate);
    }

    private static CreateInvitationRequest Request(Vacancy vacancy, CandidateProfile candidate, string? message = null)
        => new() { VacancyId = vacancy.Id, CandidateProfileId = candidate.Id, Message = message };

    private static Invitation MakeInvitation(
        CompanyProfile company, Vacancy vacancy, CandidateProfile candidate,
        InvitationStatus status = InvitationStatus.Pending) => new()
    {
        Id = Guid.NewGuid(),
        CompanyProfileId = company.Id,
        CompanyProfile = company,
        CandidateProfileId = candidate.Id,
        CandidateProfile = candidate,
        VacancyId = vacancy.Id,
        Vacancy = vacancy,
        Status = status
    };

    private void ArrangeInvitation(Invitation invitation)
        => _invitationRepositoryMock
            .Setup(r => r.GetByIdAsync(invitation.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(invitation);

    // ---------- InviteAsync ----------

    [Fact]
    public async Task InviteAsync_MessageTooLong_ReturnsValidationError()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();

        var result = await _sut.InviteAsync(
            company.UserId,
            Request(vacancy, candidate, new string('a', InvitationService.MaxMessageLength + 1)),
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task InviteAsync_CompanyNotFound_ReturnsNotFound()
    {
        var employerUserId = Guid.NewGuid();
        _companyRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((CompanyProfile?)null);

        var result = await _sut.InviteAsync(
            employerUserId,
            new CreateInvitationRequest { VacancyId = Guid.NewGuid(), CandidateProfileId = Guid.NewGuid() },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task InviteAsync_CompanyNotVerified_ReturnsForbidden()
    {
        var company = TestData.MakeCompany(verification: VerificationStatus.NotVerified);
        _companyRepositoryMock
            .Setup(r => r.GetByUserIdAsync(company.UserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(company);

        var result = await _sut.InviteAsync(
            company.UserId,
            new CreateInvitationRequest { VacancyId = Guid.NewGuid(), CandidateProfileId = Guid.NewGuid() },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _invitationRepositoryMock.Verify(r => r.Add(It.IsAny<Invitation>()), Times.Never);
    }

    [Fact]
    public async Task InviteAsync_VacancyOfAnotherCompany_ReturnsForbidden()
    {
        var (company, _, candidate) = ArrangeHappyPath();
        var foreignVacancy = TestData.MakeVacancy(TestData.MakeCompany(), VacancyStatus.Active);
        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(foreignVacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(foreignVacancy);

        var result = await _sut.InviteAsync(company.UserId, Request(foreignVacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }

    [Fact]
    public async Task InviteAsync_VacancyNotActive_ReturnsValidationError()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        vacancy.Status = VacancyStatus.Closed;

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task InviteAsync_CandidateAccountInactive_ReturnsNotFound()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        candidate.User.IsActive = false;

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task InviteAsync_HiddenCandidateWithoutPriorApplication_ReturnsForbidden()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        candidate.IsVisibleToEmployers = false;

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _invitationRepositoryMock.Verify(r => r.Add(It.IsAny<Invitation>()), Times.Never);
    }

    [Fact]
    public async Task InviteAsync_HiddenCandidateWhoAppliedToCompanyBefore_IsAllowed()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        candidate.IsVisibleToEmployers = false;
        _applicationRepositoryMock
            .Setup(r => r.ExistsForCandidateAndCompanyAsync(candidate.Id, company.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task InviteAsync_CandidateAlreadyApplied_ReturnsConflict()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        _applicationRepositoryMock
            .Setup(r => r.ExistsAsync(candidate.Id, vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
    }

    [Fact]
    public async Task InviteAsync_AlreadyInvited_ReturnsConflict()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        _invitationRepositoryMock
            .Setup(r => r.ExistsAsync(candidate.Id, vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
        _invitationRepositoryMock.Verify(r => r.Add(It.IsAny<Invitation>()), Times.Never);
    }

    [Fact]
    public async Task InviteAsync_FreeDailyLimitReached_ReturnsForbidden()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        _invitationRepositoryMock
            .Setup(r => r.CountCreatedSinceAsync(company.Id, It.IsAny<DateTime>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(TierRules.FreeInvitationsPerDay);

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _invitationRepositoryMock.Verify(r => r.Add(It.IsAny<Invitation>()), Times.Never);
    }

    [Fact]
    public async Task InviteAsync_ProCompanyAboveFreeLimit_IsAllowed()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();
        company.Tier = CompanyTier.Pro;
        company.TierExpiresAt = DateTime.UtcNow.AddDays(10);
        _invitationRepositoryMock
            .Setup(r => r.CountCreatedSinceAsync(company.Id, It.IsAny<DateTime>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(TierRules.FreeInvitationsPerDay);

        var result = await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
    }

    [Fact]
    public async Task InviteAsync_Valid_SavesPendingInvitationAndNotifiesCandidate()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();

        var result = await _sut.InviteAsync(
            company.UserId,
            Request(vacancy, candidate, "  Ждём вас на собеседование  "),
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(InvitationStatus.Pending);
        result.Data.Message.Should().Be("Ждём вас на собеседование");
        result.Data.CompanyName.Should().Be("TestCo");

        _invitationRepositoryMock.Verify(r => r.Add(It.Is<Invitation>(i =>
            i.CompanyProfileId == company.Id
            && i.CandidateProfileId == candidate.Id
            && i.VacancyId == vacancy.Id
            && i.Status == InvitationStatus.Pending)), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        _notificationServiceMock.Verify(n => n.CreateAsync(
            candidate.UserId,
            NotificationType.InvitationReceived,
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    // ---------- AcceptAsync ----------

    [Fact]
    public async Task AcceptAsync_InvitationOfAnotherCandidate_ReturnsNotFound()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var invitation = MakeInvitation(company, vacancy, MakeCandidate());
        ArrangeInvitation(invitation);

        var result = await _sut.AcceptAsync(Guid.NewGuid(), invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
        _jobApplicationServiceMock.Verify(s => s.ApplyAsync(
            It.IsAny<Guid>(), It.IsAny<Guid>(), It.IsAny<CreateJobApplicationRequest>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task AcceptAsync_AlreadyProcessed_ReturnsValidationError()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate, InvitationStatus.Declined);
        ArrangeInvitation(invitation);

        var result = await _sut.AcceptAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task AcceptAsync_Valid_CreatesApplicationAndMarksInvitationAccepted()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate);
        ArrangeInvitation(invitation);

        _jobApplicationServiceMock
            .Setup(s => s.ApplyAsync(candidate.UserId, vacancy.Id, It.IsAny<CreateJobApplicationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<JobApplicationResponse>.Ok(new JobApplicationResponse()));

        var result = await _sut.AcceptAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        invitation.Status.Should().Be(InvitationStatus.Accepted);
        invitation.RespondedAt.Should().NotBeNull();
        _invitationRepositoryMock.Verify(r => r.Update(invitation), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task AcceptAsync_CandidateAlreadyApplied_ClosesInvitationAndReturnsConflict()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate);
        ArrangeInvitation(invitation);

        _jobApplicationServiceMock
            .Setup(s => s.ApplyAsync(candidate.UserId, vacancy.Id, It.IsAny<CreateJobApplicationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<JobApplicationResponse>.Fail("already applied", ErrorType.Conflict));

        var result = await _sut.AcceptAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
        invitation.Status.Should().Be(InvitationStatus.Accepted);
    }

    [Fact]
    public async Task AcceptAsync_VacancyClosed_KeepsInvitationPending()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Closed);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate);
        ArrangeInvitation(invitation);

        _jobApplicationServiceMock
            .Setup(s => s.ApplyAsync(candidate.UserId, vacancy.Id, It.IsAny<CreateJobApplicationRequest>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(Result<JobApplicationResponse>.Fail("closed", ErrorType.Validation));

        var result = await _sut.AcceptAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        invitation.Status.Should().Be(InvitationStatus.Pending);
        _invitationRepositoryMock.Verify(r => r.Update(It.IsAny<Invitation>()), Times.Never);
    }

    // ---------- DeclineAsync ----------

    [Fact]
    public async Task DeclineAsync_Valid_MarksDeclinedAndNotifiesCompany()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate);
        ArrangeInvitation(invitation);

        var result = await _sut.DeclineAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(InvitationStatus.Declined);
        invitation.Status.Should().Be(InvitationStatus.Declined);
        _notificationServiceMock.Verify(n => n.CreateAsync(
            company.UserId,
            NotificationType.InvitationDeclined,
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task DeclineAsync_AlreadyAccepted_ReturnsValidationError()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        var candidate = MakeCandidate();
        var invitation = MakeInvitation(company, vacancy, candidate, InvitationStatus.Accepted);
        ArrangeInvitation(invitation);

        var result = await _sut.DeclineAsync(candidate.UserId, invitation.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
        _notificationServiceMock.Verify(n => n.CreateAsync(
            It.IsAny<Guid>(), It.IsAny<NotificationType>(), It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<Guid?>(), It.IsAny<CancellationToken>()), Times.Never);
    }
    
        [Fact]
    public async Task InviteAsync_Valid_InvalidatesSubscriptionCache()
    {
        var (company, vacancy, candidate) = ArrangeHappyPath();

        await _sut.InviteAsync(company.UserId, Request(vacancy, candidate), CancellationToken.None);

        _cacheServiceMock.Verify(
            c => c.RemoveAsync(CacheKeys.Subscription(company.UserId), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task GetBlockedVacanciesAsync_CompanyNotFound_ReturnsNotFound()
    {
        var employerUserId = Guid.NewGuid();
        _companyRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((CompanyProfile?)null);

        var result = await _sut.GetBlockedVacanciesAsync(employerUserId, Guid.NewGuid(), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task GetBlockedVacanciesAsync_ReturnsAppliedInvitedAndDeclinedWithoutDuplicates()
    {
        var company = TestData.MakeCompany();
        var candidate = MakeCandidate();
        var applied = Guid.NewGuid();
        var pending = Guid.NewGuid();
        var declined = Guid.NewGuid();

        _companyRepositoryMock
            .Setup(r => r.GetByUserIdAsync(company.UserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(company);
        _applicationRepositoryMock
            .Setup(r => r.GetVacancyIdsByCandidateAndCompanyAsync(candidate.Id, company.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Guid> { applied });
        _invitationRepositoryMock
            .Setup(r => r.GetByCandidateAndCompanyAsync(candidate.Id, company.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Invitation>
            {
                new() { VacancyId = applied, Status = InvitationStatus.Accepted },
                new() { VacancyId = pending, Status = InvitationStatus.Pending },
                new() { VacancyId = declined, Status = InvitationStatus.Declined }
            });

        var result = await _sut.GetBlockedVacanciesAsync(company.UserId, candidate.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data.Should().HaveCount(3);
        result.Data!.Single(b => b.VacancyId == applied).Reason.Should().Be(InvitationBlockReason.Applied);
        result.Data!.Single(b => b.VacancyId == pending).Reason.Should().Be(InvitationBlockReason.Invited);
        result.Data!.Single(b => b.VacancyId == declined).Reason.Should().Be(InvitationBlockReason.Declined);
    }
}