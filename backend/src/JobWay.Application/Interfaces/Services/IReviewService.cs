using JobWay.Application.Common;
using JobWay.Application.DTOs.Review.Request;
using JobWay.Application.DTOs.Review.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IReviewService
{
    Task<Result<ReviewResponse>> CreateAsync(Guid currentUserId, CreateReviewRequest request, CancellationToken cancellationToken);
    Task<Result<PagedResult<ReviewResponse>>> GetForUserAsync(Guid revieweeUserId, ReviewsFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<double>> GetAverageRatingAsync(Guid userId, CancellationToken cancellationToken);
}