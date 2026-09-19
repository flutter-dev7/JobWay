using FluentAssertions;
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

public class JobApplicationServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<ICandidateProfileRepository> _candidateProfileRepositoryMock = new();
    private readonly Mock<ICompanyProfileRepository> _companyProfileRepositoryMock = new();
    private readonly Mock<IVacancyRepository> _vacancyRepositoryMock = new();
    private readonly Mock<IJobApplicationRepository> _jobApplicationRepositoryMock = new();
    private readonly Mock<IMatchingService> _matchingServiceMock = new();
    private readonly Mock<INotificationService> _notificationServiceMock = new();

    private readonly JobApplicationService _sut;

    public JobApplicationServiceTests()
    {
        _unitOfWorkMock.Setup(u => u.CandidateProfiles).Returns(_candidateProfileRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.CompanyProfiles).Returns(_companyProfileRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Vacancies).Returns(_vacancyRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.JobApplications).Returns(_jobApplicationRepositoryMock.Object);

        _sut = new JobApplicationService(_unitOfWorkMock.Object, _matchingServiceMock.Object, _notificationServiceMock.Object);
    }

    [Fact]
    public async Task ApplyAsync_AlreadyApplied_ReturnsConflict()
    {
        var candidateUserId = Guid.NewGuid();
        var vacancyId = Guid.NewGuid();

        var candidateProfile = new CandidateProfile { Id = Guid.NewGuid(), UserId = candidateUserId, FullName = "Test", Skills = [] };
        var vacancy = new Vacancy
        {
            Id = vacancyId,
            CompanyProfile = new CompanyProfile { CompanyName = "TestCo" },
            Status = VacancyStatus.Active,
            Title = "Dev",
            Description = "Desc",
            RequiredSkills = []
        };

        _candidateProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(candidateUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(candidateProfile);

        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancyId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

        _jobApplicationRepositoryMock
            .Setup(r => r.ExistsAsync(candidateProfile.Id, vacancyId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(true);

        var result = await _sut.ApplyAsync(candidateUserId, vacancyId, new CreateJobApplicationRequest(), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
    }

    [Fact]
    public async Task ApplyAsync_VacancyNotActive_ReturnsValidationError()
    {
        var candidateUserId = Guid.NewGuid();
        var vacancyId = Guid.NewGuid();

        var candidateProfile = new CandidateProfile { Id = Guid.NewGuid(), UserId = candidateUserId, FullName = "Test", Skills = [] };
        var vacancy = new Vacancy
        {
            Id = vacancyId,
            CompanyProfile = new CompanyProfile { CompanyName = "TestCo" },
            Status = VacancyStatus.Draft,
            Title = "Dev",
            Description = "Desc",
            RequiredSkills = []
        };

        _candidateProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(candidateUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(candidateProfile);

        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancyId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

        var result = await _sut.ApplyAsync(candidateUserId, vacancyId, new CreateJobApplicationRequest(), CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task ApplyAsync_Valid_CreatesApplicationAndNotifiesEmployer()
    {
        var candidateUserId = Guid.NewGuid();
        var employerUserId = Guid.NewGuid();
        var vacancyId = Guid.NewGuid();

        var candidateProfile = new CandidateProfile { Id = Guid.NewGuid(), UserId = candidateUserId, FullName = "Test", Skills = [] };
        var companyProfile = new CompanyProfile { UserId = employerUserId, CompanyName = "TestCo" };
        var vacancy = new Vacancy
        {
            Id = vacancyId,
            CompanyProfile = companyProfile,
            Status = VacancyStatus.Active,
            Title = "Dev",
            Description = "Desc",
            RequiredSkills = []
        };

        _candidateProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(candidateUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(candidateProfile);

        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancyId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

        _jobApplicationRepositoryMock
            .Setup(r => r.ExistsAsync(candidateProfile.Id, vacancyId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(false);

        _matchingServiceMock
            .Setup(m => m.Calculate(candidateProfile.Skills, vacancy.RequiredSkills))
            .Returns(new MatchResult { ScorePercent = 80, MatchedSkills = [], MissingSkills = [] });

        var result = await _sut.ApplyAsync(candidateUserId, vacancyId, new CreateJobApplicationRequest { CoverMessage = "Hi" }, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.MatchScore.Should().Be(80);

        _jobApplicationRepositoryMock.Verify(r => r.Add(It.Is<JobApplication>(a => a.MatchScore == 80)), Times.Once);
        _notificationServiceMock.Verify(n => n.CreateAsync(
            employerUserId,
            NotificationType.NewApplication,
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task UpdateStatusAsync_NotOwner_ReturnsForbidden()
    {
        var employerUserId = Guid.NewGuid();
        var applicationId = Guid.NewGuid();

        var otherCompanyId = Guid.NewGuid();
        var application = new JobApplication
        {
            Id = applicationId,
            CandidateProfile = new CandidateProfile { FullName = "Test", Skills = [] },
            Vacancy = new Vacancy
            {
                CompanyProfileId = otherCompanyId,
                CompanyProfile = new CompanyProfile { Id = otherCompanyId, CompanyName = "OtherCo" },
                Title = "Dev",
                Description = "Desc",
                RequiredSkills = []
            }
        };

        _jobApplicationRepositoryMock
            .Setup(r => r.GetByIdAsync(applicationId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(application);

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new CompanyProfile { Id = Guid.NewGuid(), CompanyName = "MyCo" });

        var result = await _sut.UpdateStatusAsync(employerUserId, applicationId, new UpdateJobApplicationStatusRequest { Status = ApplicationStatus.Accepted }, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }
}