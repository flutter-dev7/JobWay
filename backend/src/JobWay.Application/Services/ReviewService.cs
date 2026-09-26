using JobWay.Application.Common;
using JobWay.Application.DTOs.Review.Request;
using JobWay.Application.DTOs.Review.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class ReviewService : IReviewService
{
    private const string AverageRatingKeyPrefix = "review-avg-rating:";
    private static readonly TimeSpan AverageRatingCacheExpiry = TimeSpan.FromHours(6);

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;
    private readonly INotificationService _notificationService;

    public ReviewService(IUnitOfWork unitOfWork, ICacheService cacheService, INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
        _notificationService = notificationService;
    }

    public async Task<Result<ReviewResponse>> CreateAsync(Guid currentUserId, CreateReviewRequest request, CancellationToken cancellationToken)
    {
        if (request.Rating is < 1 or > 5)
            return Result<ReviewResponse>.Fail("Рейтинг должен быть от 1 до 5.", ErrorType.Validation);

        var application = await _unitOfWork.JobApplications.GetWithParticipantsAsync(request.JobApplicationId, cancellationToken);
        if (application is null)
            return Result<ReviewResponse>.Fail("Отклик не найден.", ErrorType.NotFound);

        var candidateUserId = application.CandidateProfile.UserId;
        var companyUserId = application.Vacancy.CompanyProfile.UserId;

        ReviewType type;
        Guid revieweeUserId;
        string reviewerName;
        string? reviewerPhotoUrl;

        if (currentUserId == candidateUserId)
        {
            type = ReviewType.CandidateToCompany;
            revieweeUserId = companyUserId;
            reviewerName = application.CandidateProfile.FullName;
            reviewerPhotoUrl = application.CandidateProfile.PhotoUrl;
        }
        else if (currentUserId == companyUserId)
        {
            type = ReviewType.CompanyToCandidate;
            revieweeUserId = candidateUserId;
            reviewerName = application.Vacancy.CompanyProfile.CompanyName;
            reviewerPhotoUrl = application.Vacancy.CompanyProfile.LogoUrl;
        }
        else
        {
            return Result<ReviewResponse>.Fail("Вы не участник этого отклика.", ErrorType.Unauthorized);
        }

        var existing = await _unitOfWork.Reviews.GetByApplicationAndTypeAsync(request.JobApplicationId, type, cancellationToken);
        if (existing is not null)
            return Result<ReviewResponse>.Fail("Вы уже оставили отзыв по этому отклику.", ErrorType.Conflict);

        var review = new Domain.Entities.Review
        {
            JobApplicationId = request.JobApplicationId,
            Type = type,
            ReviewerUserId = currentUserId,
            RevieweeUserId = revieweeUserId,
            Rating = request.Rating,
            Comment = request.Comment,
            CreatedAt = DateTime.UtcNow,
            ReviewerName = reviewerName,
            ReviewerPhotoUrl = reviewerPhotoUrl
        };

        _unitOfWork.Reviews.Add(review);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(AverageRatingKeyPrefix + revieweeUserId, cancellationToken);

        await _notificationService.CreateAsync(
            revieweeUserId,
            NotificationType.NewReview,
            "Новый отзыв",
            $"{reviewerName} оставил(а) вам отзыв — {request.Rating} из 5",
            review.Id,
            cancellationToken);

        return Result<ReviewResponse>.Ok(Map(review));
    }

    public async Task<Result<List<ReviewResponse>>> GetForUserAsync(Guid revieweeUserId, CancellationToken cancellationToken)
    {
        var reviews = await _unitOfWork.Reviews.GetByRevieweeAsync(revieweeUserId, cancellationToken);
        return Result<List<ReviewResponse>>.Ok(reviews.Select(Map).ToList());
    }

    public async Task<Result<double>> GetAverageRatingAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cacheKey = AverageRatingKeyPrefix + userId;
        var cached = await _cacheService.GetAsync(cacheKey, cancellationToken);

        if (cached is not null && double.TryParse(cached, out var cachedValue))
            return Result<double>.Ok(cachedValue);

        var reviews = await _unitOfWork.Reviews.GetByRevieweeAsync(userId, cancellationToken);
        var average = reviews.Count == 0 ? 0 : reviews.Average(r => r.Rating);

        await _cacheService.SetAsync(cacheKey, average.ToString("F2"), AverageRatingCacheExpiry, cancellationToken);

        return Result<double>.Ok(average);
    }

    private static ReviewResponse Map(Domain.Entities.Review r) => new()
    {
        Id = r.Id,
        Type = r.Type,
        ReviewerUserId = r.ReviewerUserId,
        RevieweeUserId = r.RevieweeUserId,
        Rating = r.Rating,
        Comment = r.Comment,
        CreatedAt = r.CreatedAt,
        ReviewerName = r.ReviewerName,
        ReviewerPhotoUrl = r.ReviewerPhotoUrl
    };
}