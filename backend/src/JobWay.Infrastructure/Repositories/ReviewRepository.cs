using JobWay.Application.DTOs.Review.Request;
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
            .Where(r => r.JobApplicationId != null && jobApplicationIds.Contains(r.JobApplicationId.Value) && r.Type == type)
            .Select(r => r.JobApplicationId!.Value)
            .ToListAsync(cancellationToken);

        return ids.ToHashSet();
    }
    
    public async Task<(List<Review> Items, int TotalCount)> GetPagedByRevieweeAsync(
        Guid revieweeUserId, ReviewsFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.Reviews.Where(r => r.RevieweeUserId == revieweeUserId);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(r => r.CreatedAt)
            .ThenBy(r => r.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public async Task<double> GetAverageRatingAsync(Guid revieweeUserId, CancellationToken cancellationToken)
    {
        var average = await _context.Reviews
            .Where(r => r.RevieweeUserId == revieweeUserId)
            .Select(r => (double?)r.Rating)
            .AverageAsync(cancellationToken);

        return average ?? 0;
    }

    public void Add(Review review) => _context.Reviews.Add(review);
}