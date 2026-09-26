// tests/JobWay.UnitTests/Services/VacancyServiceTests.cs — заменить целиком
using FluentAssertions;
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

        // всегда возвращаем "нет в кэше", чтобы тесты работали с реальными данными из репозиториев, не из кэша
        _cacheServiceMock
            .Setup(c => c.GetAsync(It.IsAny<string>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((string?)null);

        _sut = new VacancyService(
            _unitOfWorkMock.Object,
            _cacheServiceMock.Object,
            _matchingServiceMock.Object,
            _notificationServiceMock.Object);
    }

    [Fact]
    public async Task CreateAsync_CompanyProfileNotFound_ReturnsNotFound()
    {
        var employerUserId = Guid.NewGuid();

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((CompanyProfile?)null);

        var result = await _sut.CreateAsync(employerUserId, new CreateVacancyRequest { Title = "T", Description = "D" }, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task PublishAsync_CompanyNotVerified_ReturnsForbidden()
    {
        var employerUserId = Guid.NewGuid();
        var vacancyId = Guid.NewGuid();

        var companyProfile = new CompanyProfile
        {
            Id = Guid.NewGuid(),
            UserId = employerUserId,
            CompanyName = "TestCo",
            VerificationStatus = VerificationStatus.NotVerified
        };

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(companyProfile);

        var result = await _sut.PublishAsync(employerUserId, vacancyId, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);

        _vacancyRepositoryMock.Verify(r => r.GetByIdAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Never);
    }

    [Fact]
    public async Task PublishAsync_VerifiedCompanyAndOwnsVacancy_ActivatesVacancy()
    {
        var employerUserId = Guid.NewGuid();
        var companyProfile = new CompanyProfile
        {
            Id = Guid.NewGuid(),
            UserId = employerUserId,
            CompanyName = "TestCo",
            VerificationStatus = VerificationStatus.Verified
        };

        var vacancy = new Vacancy
        {
            Id = Guid.NewGuid(),
            CompanyProfileId = companyProfile.Id,
            CompanyProfile = companyProfile,
            Title = "Dev",
            Description = "Desc",
            Status = VacancyStatus.Draft,
            RequiredSkills = []
        };

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(companyProfile);

        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

        var result = await _sut.PublishAsync(employerUserId, vacancy.Id, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Status.Should().Be(VacancyStatus.Active);

        _vacancyRepositoryMock.Verify(r => r.Update(It.Is<Vacancy>(v => v.Status == VacancyStatus.Active)), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task UpdateAsync_NotOwner_ReturnsForbidden()
    {
        var employerUserId = Guid.NewGuid();
        var companyProfile = new CompanyProfile { Id = Guid.NewGuid(), UserId = employerUserId, CompanyName = "TestCo" };

        var otherCompanyId = Guid.NewGuid();
        var vacancy = new Vacancy
        {
            Id = Guid.NewGuid(),
            CompanyProfileId = otherCompanyId,
            CompanyProfile = new CompanyProfile { Id = otherCompanyId, CompanyName = "OtherCo" },
            Title = "Dev",
            Description = "Desc"
        };

        _companyProfileRepositoryMock
            .Setup(r => r.GetByUserIdAsync(employerUserId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(companyProfile);

        _vacancyRepositoryMock
            .Setup(r => r.GetByIdAsync(vacancy.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(vacancy);

        var request = new UpdateVacancyRequest { Title = "New", Description = "New Desc" };

        var result = await _sut.UpdateAsync(employerUserId, vacancy.Id, request, CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Forbidden);
    }
}