using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class ReviewRepository : IReviewRepository
{
    private readonly AppDbContext _context;

    public ReviewRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<Review?> GetByApplicationAndTypeAsync(Guid jobApplicationId, ReviewType type, CancellationToken cancellationToken)
        => _context.Reviews.FirstOrDefaultAsync(r => r.JobApplicationId == jobApplicationId && r.Type == type, cancellationToken);

    public Task<List<Review>> GetByRevieweeAsync(Guid revieweeUserId, CancellationToken cancellationToken)
        => _context.Reviews.Where(r => r.RevieweeUserId == revieweeUserId)
            .OrderByDescending(r => r.CreatedAt)
            .ToListAsync(cancellationToken);
    
    public async Task<HashSet<Guid>> GetReviewedApplicationIdsAsync(List<Guid> jobApplicationIds, ReviewType type, CancellationToken cancellationToken)
    {
        var ids = await _context.Reviews
            .Where(r => jobApplicationIds.Contains(r.JobApplicationId) && r.Type == type)
            .Select(r => r.JobApplicationId)
            .ToListAsync(cancellationToken);

        return ids.ToHashSet();
    }

    public void Add(Review review) => _context.Reviews.Add(review);
}