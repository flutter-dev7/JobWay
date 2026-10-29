using FluentAssertions;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using Moq;
using Xunit;

namespace JobWay.UnitTests.Services;

public class VacancyServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<ICompanyProfileRepository> _companyProfileRepositoryMock = new();
    private readonly Mock<IVacancyRepository> _vacancyRepositoryMock = new();
    private readonly Mock<ISkillRepository> _skillRepositoryMock = new();
    private readonly Mock<ICacheService> _cacheServiceMock = new();
    private readonly Mock<ICandidateProfileRepository> _candidateProfileRepositoryMock = new();
    private readonly Mock<IMatchingService> _matchingServiceMock = new();
    private readonly Mock<INotificationService> _notificationServiceMock = new();

    private readonly VacancyService _sut;

    public VacancyServiceTests()
    {
        _unitOfWorkMock.Setup(u => u.CompanyProfiles).Returns(_companyProfileRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Vacancies).Returns(_vacancyRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Skills).Returns(_skillRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.CandidateProfiles).Returns(_candidateProfileRepositoryMock.Object);

        // Всегда «нет в кэше»: тесты работают с данными репозиториев
        _cacheServiceMock
            .Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((string?)null);

        // После публикации сервис рассылает уведомления подходящим кандидатам: по умолчанию их нет
        _candidateProfileRepositoryMock
            .Setup(r => r.GetAllWithSkillsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<CandidateProfile>());

        _sut = new VacancyService(
            _unitOfWorkMock.Object,
            _cacheServiceMock.Object,
            _matchingServiceMock.Object,
            _notificationServiceMock.Object);
    }

    private void ArrangeCompany(CompanyProfile company)
        => _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(company.UserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(company);

    private void ArrangeVacancy(Vacancy vacancy)
        => _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

    private void ArrangeActiveCount(CompanyProfile company, int count)
        => _vacancyRepositoryMock
            .Setup(r => r.CountActiveByCompanyProfileIdAsync(company.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(count);

    // ---------- CreateAsync ----------

    [Fact]
    public async Task CreateAsync_CompanyProfileNotFound_ReturnsNotFound()
    {
        var employerUserId = Guid.NewGuid();

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((CompanyProfile?)null);

        var result = await _sut.CreateAsync(
            employerUserId,
            new CreateVacancyRequest { Title = "T", Description = "D", SkillIds = [] },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task CreateAsync_InvalidVacancy_ReturnsValidationErrorAndDoesNotSave()
    {
        var company = TestData.MakeCompany();
        ArrangeCompany(company);
        _skillRepositoryMock
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Skill>());

        var result = await _sut.CreateAsync(
            company.UserId,
            new CreateVacancyRequest { Title = "T", Description = "D", SkillIds = [] },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
        _vacancyRepositoryMock.Verify(r => r.Add(It.IsAny<Vacancy>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_ValidRequest_CreatesDraft()
    {
        var company = TestData.MakeCompany();
        var skill = TestData.MakeSkill();
        ArrangeCompany(company);
        _skillRepositoryMock
            .Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Skill> { skill });

        var request = new CreateVacancyRequest
        {
            Title = "Backend developer",
            Description = "Разработка и поддержка backend-сервисов компании",
            Responsibilities = "Писать код\nПроводить ревью",
            Requirements = "Опыт от года\nЗнание C#",
            Location = "Душанбе",
            SalaryFrom = 3000,
            SalaryTo = 5000,
            SkillIds = [skill.Id]
        };

        var result = await _sut.CreateAsync(company.UserId, request, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(VacancyStatus.Draft);

        _vacancyRepositoryMock.Verify(
            r => r.Add(It.Is<Vacancy>(v => v.Title == "Backend developer" && v.Status == VacancyStatus.Draft)),
            Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    // ---------- PublishAsync ----------

    [Fact]
    public async Task PublishAsync_CompanyNotVerified_ReturnsForbidden()
    {
        var company = TestData.MakeCompany(verification: VerificationStatus.NotVerified);
        ArrangeCompany(company);

        var result = await _sut.PublishAsync(company.UserId, Guid.NewGuid(), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _vacancyRepositoryMock.Verify(r => r.GetByIdAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task PublishAsync_ValidDraft_ActivatesVacancyAndSetsThirtyDayExpiry()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.PublishAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(VacancyStatus.Active);
        result.Data.ExpiresAt.Should().BeCloseTo(
            DateTime.UtcNow.AddDays(VacancyRules.LifetimeDays), TimeSpan.FromMinutes(1));

        _vacancyRepositoryMock.Verify(r => r.Update(It.Is<Vacancy>(v => v.Status == VacancyStatus.Active)), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task PublishAsync_IncompleteDraft_ReturnsValidationError()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company);
        vacancy.Description = "Desc";
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.PublishAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
        _vacancyRepositoryMock.Verify(r => r.Update(It.IsAny<Vacancy>()), Times.Never);
    }

    [Fact]
    public async Task PublishAsync_FreeTierLimitReached_ReturnsForbidden()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);
        ArrangeActiveCount(company, TierRules.FreeActiveVacancyLimit);

        var result = await _sut.PublishAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _vacancyRepositoryMock.Verify(r => r.Update(It.IsAny<Vacancy>()), Times.Never);
    }

    [Fact]
    public async Task PublishAsync_AlreadyActive_ReturnsOkWithoutChanges()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.PublishAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        _vacancyRepositoryMock.Verify(r => r.Update(It.IsAny<Vacancy>()), Times.Never);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task PublishAsync_ArchivedVacancy_ReturnsForbidden()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Archived);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.PublishAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _vacancyRepositoryMock.Verify(r => r.Update(It.IsAny<Vacancy>()), Times.Never);
    }

    // ---------- UpdateAsync ----------

    [Fact]
    public async Task UpdateAsync_NotOwner_ReturnsForbidden()
    {
        var company = TestData.MakeCompany();
        var otherCompany = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(otherCompany);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.UpdateAsync(
            company.UserId,
            vacancy.Id,
            new UpdateVacancyRequest { Title = "New", Description = "New Desc" },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }

    // ---------- RenewAsync ----------

    [Fact]
    public async Task RenewAsync_NotOwner_ReturnsForbidden()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(TestData.MakeCompany(), VacancyStatus.Active);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.RenewAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }

    [Fact]
    public async Task RenewAsync_VacancyNotActive_ReturnsValidationError()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Closed);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.RenewAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task RenewAsync_ActiveVacanciesOverTierLimit_ReturnsForbidden()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);
        ArrangeActiveCount(company, TierRules.FreeActiveVacancyLimit + 1);

        var result = await _sut.RenewAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
        _vacancyRepositoryMock.Verify(r => r.Update(It.IsAny<Vacancy>()), Times.Never);
    }

    [Fact]
    public async Task RenewAsync_ActiveVacancyWithinLimit_ResetsExpiryToThirtyDaysFromNow()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        vacancy.ExpiresAt = DateTime.UtcNow.AddDays(5);
        vacancy.ExpiryNoticeSent = true;
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);
        ArrangeActiveCount(company, 1);

        var result = await _sut.RenewAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();

        // Срок считается от сегодня и не накапливается: 5 + 30 дней быть не должно
        result.Data!.ExpiresAt.Should().BeCloseTo(
            DateTime.UtcNow.AddDays(VacancyRules.LifetimeDays), TimeSpan.FromMinutes(1));
        vacancy.ExpiryNoticeSent.Should().BeFalse();

        _vacancyRepositoryMock.Verify(r => r.Update(vacancy), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        _cacheServiceMock.Verify(c => c.RemoveAsync(CacheKeys.Vacancy(vacancy.Id), It.IsAny<CancellationToken>()), Times.Once);
    }

    // ---------- CloseAsync ----------

    [Fact]
    public async Task CloseAsync_ActiveFeaturedVacancy_ClearsPromotionAndExpiry()
    {
        var company = TestData.MakeCompany();
        var vacancy = TestData.MakeVacancy(company, VacancyStatus.Active);
        vacancy.FeaturedUntil = DateTime.UtcNow.AddDays(3);
        vacancy.ExpiresAt = DateTime.UtcNow.AddDays(10);
        ArrangeCompany(company);
        ArrangeVacancy(vacancy);

        var result = await _sut.CloseAsync(company.UserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(VacancyStatus.Closed);
        vacancy.FeaturedUntil.Should().BeNull();
        vacancy.ExpiresAt.Should().BeNull();
    }

    // ---------- GetByIdAsync ----------

    [Fact]
    public async Task GetByIdAsync_DraftVacancy_ReturnsNotFound()
    {
        var vacancy = TestData.MakeVacancy(TestData.MakeCompany(), VacancyStatus.Draft);
        ArrangeVacancy(vacancy);

        var result = await _sut.GetByIdAsync(vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }
}