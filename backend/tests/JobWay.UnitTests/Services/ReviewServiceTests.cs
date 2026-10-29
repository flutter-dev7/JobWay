using FluentAssertions;
using JobWay.Application.DTOs.Review.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Application.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using Moq;
using Xunit;
using ReviewEntity = JobWay.Domain.Entities.Review;

namespace JobWay.UnitTests.Services;

public class ReviewServiceTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock = new();
    private readonly Mock<IJobApplicationRepository> _jobApplicationRepositoryMock = new();
    private readonly Mock<IReviewRepository> _reviewRepositoryMock = new();
    private readonly Mock<ICacheService> _cacheServiceMock = new();
    private readonly Mock<INotificationService> _notificationServiceMock = new();

    private readonly ReviewService _sut;

    public ReviewServiceTests()
    {
        _unitOfWorkMock.Setup(u => u.JobApplications).Returns(_jobApplicationRepositoryMock.Object);
        _unitOfWorkMock.Setup(u => u.Reviews).Returns(_reviewRepositoryMock.Object);

        _sut = new ReviewService(_unitOfWorkMock.Object, _cacheServiceMock.Object, _notificationServiceMock.Object);
    }

    private static JobApplication MakeApplication(Guid candidateUserId, Guid companyUserId) => new()
    {
        Id = Guid.NewGuid(),
        CandidateProfile = new CandidateProfile { UserId = candidateUserId, FullName = "Candidate Name" },
        Vacancy = new Vacancy
        {
            Title = "Dev",
            Description = "Desc",
            CompanyProfile = new CompanyProfile { UserId = companyUserId, CompanyName = "TestCo" }
        }
    };

    private void ArrangeApplication(JobApplication application)
        => _jobApplicationRepositoryMock
            .Setup(r => r.GetWithParticipantsAsync(application.Id, It.IsAny<CancellationToken>()))
            .ReturnsAsync(application);

    [Theory]
    [InlineData(0)]
    [InlineData(6)]
    [InlineData(-1)]
    public async Task CreateAsync_RatingOutOfRange_ReturnsValidationError(int rating)
    {
        var result = await _sut.CreateAsync(
            Guid.NewGuid(),
            new CreateReviewRequest { JobApplicationId = Guid.NewGuid(), Rating = rating },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Validation);
    }

    [Fact]
    public async Task CreateAsync_ApplicationNotFound_ReturnsNotFound()
    {
        var applicationId = Guid.NewGuid();
        _jobApplicationRepositoryMock
            .Setup(r => r.GetWithParticipantsAsync(applicationId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((JobApplication?)null);

        var result = await _sut.CreateAsync(
            Guid.NewGuid(),
            new CreateReviewRequest { JobApplicationId = applicationId, Rating = 5 },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.NotFound);
    }

    [Fact]
    public async Task CreateAsync_UserIsNotParticipant_ReturnsUnauthorized()
    {
        var application = MakeApplication(Guid.NewGuid(), Guid.NewGuid());
        ArrangeApplication(application);

        var result = await _sut.CreateAsync(
            Guid.NewGuid(),
            new CreateReviewRequest { JobApplicationId = application.Id, Rating = 5 },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Unauthorized);
        _reviewRepositoryMock.Verify(r => r.Add(It.IsAny<ReviewEntity>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_ReviewAlreadyExists_ReturnsConflict()
    {
        var candidateUserId = Guid.NewGuid();
        var application = MakeApplication(candidateUserId, Guid.NewGuid());
        ArrangeApplication(application);
        _reviewRepositoryMock
            .Setup(r => r.GetByApplicationAndTypeAsync(application.Id, ReviewType.CandidateToCompany, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new ReviewEntity());

        var result = await _sut.CreateAsync(
            candidateUserId,
            new CreateReviewRequest { JobApplicationId = application.Id, Rating = 4 },
            CancellationToken.None);

        result.IsSuccess.Should().BeFalse();
        result.ErrorType.Should().Be(ErrorType.Conflict);
        _reviewRepositoryMock.Verify(r => r.Add(It.IsAny<ReviewEntity>()), Times.Never);
    }

    [Fact]
    public async Task CreateAsync_CandidateReviewsCompany_SavesReviewAndNotifiesCompany()
    {
        var candidateUserId = Guid.NewGuid();
        var companyUserId = Guid.NewGuid();
        var application = MakeApplication(candidateUserId, companyUserId);
        ArrangeApplication(application);
        _reviewRepositoryMock
            .Setup(r => r.GetByApplicationAndTypeAsync(application.Id, ReviewType.CandidateToCompany, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ReviewEntity?)null);

        var result = await _sut.CreateAsync(
            candidateUserId,
            new CreateReviewRequest { JobApplicationId = application.Id, Rating = 5, Comment = "Отлично" },
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data!.Type.Should().Be(ReviewType.CandidateToCompany);

        _reviewRepositoryMock.Verify(r => r.Add(It.Is<ReviewEntity>(x =>
            x.Type == ReviewType.CandidateToCompany
            && x.ReviewerUserId == candidateUserId
            && x.RevieweeUserId == companyUserId
            && x.Rating == 5
            && x.ReviewerName == "Candidate Name")), Times.Once);

        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
        _cacheServiceMock.Verify(c => c.RemoveAsync("review-avg-rating:" + companyUserId, It.IsAny<CancellationToken>()), Times.Once);
        _notificationServiceMock.Verify(n => n.CreateAsync(
            companyUserId,
            NotificationType.NewReview,
            It.IsAny<string>(),
            It.IsAny<string>(),
            It.IsAny<Guid?>(),
            It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task CreateAsync_CompanyReviewsCandidate_UsesCompanyNameAsReviewer()
    {
        var candidateUserId = Guid.NewGuid();
        var companyUserId = Guid.NewGuid();
        var application = MakeApplication(candidateUserId, companyUserId);
        ArrangeApplication(application);
        _reviewRepositoryMock
            .Setup(r => r.GetByApplicationAndTypeAsync(application.Id, ReviewType.CompanyToCandidate, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ReviewEntity?)null);

        var result = await _sut.CreateAsync(
            companyUserId,
            new CreateReviewRequest { JobApplicationId = application.Id, Rating = 3 },
            CancellationToken.None);

        result.IsSuccess.Should().BeTrue();

        _reviewRepositoryMock.Verify(r => r.Add(It.Is<ReviewEntity>(x =>
            x.Type == ReviewType.CompanyToCandidate
            && x.RevieweeUserId == candidateUserId
            && x.ReviewerName == "TestCo")), Times.Once);
    }

    [Fact]
    public async Task GetAverageRatingAsync_ValueInCache_DoesNotHitRepository()
    {
        var userId = Guid.NewGuid();
        _cacheServiceMock
            .Setup(c => c.GetAsync("review-avg-rating:" + userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(4.5.ToString("F2"));

        var result = await _sut.GetAverageRatingAsync(userId, CancellationToken.None);

        result.IsSuccess.Should().BeTrue();
        result.Data.Should().Be(4.5);
        _reviewRepositoryMock.Verify(r => r.GetAverageRatingAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()), Times.Never);
    }
}