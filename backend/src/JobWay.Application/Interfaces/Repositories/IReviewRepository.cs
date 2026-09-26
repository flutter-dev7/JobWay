using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Interfaces.Repositories;

public interface IReviewRepository
{
    Task<Review?> GetByApplicationAndTypeAsync(Guid jobApplicationId, ReviewType type, CancellationToken cancellationToken);
    Task<List<Review>> GetByRevieweeAsync(Guid revieweeUserId, CancellationToken cancellationToken);
    Task<HashSet<Guid>> GetReviewedApplicationIdsAsync(List<Guid> jobApplicationIds, ReviewType type, CancellationToken cancellationToken);
    void Add(Review review);
}