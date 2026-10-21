using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.DTOs.Admin.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    
    public Task<List<Guid>> GetAdminUserIdsAsync(CancellationToken cancellationToken)
        => _context.Users
            .Where(u => u.Role == UserRole.Admin && u.IsActive)
            .Select(u => u.Id)
            .ToListAsync(cancellationToken);

    public Task<User?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.RefreshToken == refreshToken, cancellationToken);

    public Task<bool> ExistsAsync(string email, CancellationToken cancellationToken)
        => _context.Users.AnyAsync(u => u.Email == email, cancellationToken);

    public Task<List<User>> GetAllAsync(CancellationToken cancellationToken)
        => _context.Users.ToListAsync(cancellationToken);
    
    public async Task<(List<AdminUserRow> Items, int TotalCount)> GetPagedForAdminAsync(
        AdminUsersFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.Users.AsQueryable();

        if (filter.Role is not null)
            query = query.Where(u => u.Role == filter.Role);

        if (filter.IsActive is not null)
            query = query.Where(u => u.IsActive == filter.IsActive);

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(u => EF.Functions.ILike(u.Email, $"%{search}%"));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(u => u.CreatedAt)
            .ThenBy(u => u.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Select(u => new AdminUserRow(
                u.Id,
                u.Email,
                u.Role,
                u.IsActive,
                _context.CandidateProfiles.Where(c => c.UserId == u.Id).Select(c => c.PhotoUrl).FirstOrDefault()
                ?? _context.CompanyProfiles.Where(c => c.UserId == u.Id).Select(c => c.LogoUrl).FirstOrDefault(),
                _context.CandidateProfiles.Where(c => c.UserId == u.Id).Select(c => (Guid?)c.Id).FirstOrDefault()
                ?? _context.CompanyProfiles.Where(c => c.UserId == u.Id).Select(c => (Guid?)c.Id).FirstOrDefault()))
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
    
    public async Task<List<string>> DeleteWithAllDataAsync(Guid userId, CancellationToken cancellationToken)
    {
        await using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);

        var candidate = await _context.CandidateProfiles
            .Where(c => c.UserId == userId)
            .Select(c => new { c.PhotoUrl, c.ResumeFileUrl })
            .FirstOrDefaultAsync(cancellationToken);

        var company = await _context.CompanyProfiles
            .Where(c => c.UserId == userId)
            .Select(c => new { c.LogoUrl })
            .FirstOrDefaultAsync(cancellationToken);

        var fileUrls = new[] { candidate?.PhotoUrl, candidate?.ResumeFileUrl, company?.LogoUrl }
            .Where(url => !string.IsNullOrWhiteSpace(url))
            .Select(url => url!)
            .ToList();

        var applicationIds = _context.JobApplications
            .Where(a => a.CandidateProfile.UserId == userId || a.Vacancy.CompanyProfile.UserId == userId)
            .Select(a => a.Id);
        var vacancyIds = _context.Vacancies
            .Where(v => v.CompanyProfile.UserId == userId)
            .Select(v => v.Id);
        var writtenReviewIds = _context.Reviews
            .Where(r => r.ReviewerUserId == userId)
            .Select(r => r.Id);

        // Свои уведомления и чужие, которые ссылаются на удаляемые данные (в их тексте есть имя)
        await _context.Notifications
            .Where(n => n.UserId == userId
                        || (n.RelatedEntityId != null && (
                            n.RelatedEntityId == userId
                            || applicationIds.Contains(n.RelatedEntityId.Value)
                            || vacancyIds.Contains(n.RelatedEntityId.Value)
                            || writtenReviewIds.Contains(n.RelatedEntityId.Value))))
            .ExecuteDeleteAsync(cancellationToken);

        // Отзывы о нём удаляем, отзывы от него оставляем обезличенными
        await _context.Reviews
            .Where(r => r.RevieweeUserId == userId)
            .ExecuteDeleteAsync(cancellationToken);

        await _context.Reviews
            .Where(r => r.ReviewerUserId == userId)
            .ExecuteUpdateAsync(s => s
                .SetProperty(r => r.ReviewerName, "Пользователь удалён")
                .SetProperty(r => r.ReviewerPhotoUrl, (string?)null), cancellationToken);

        await _context.DeviceTokens.Where(t => t.UserId == userId).ExecuteDeleteAsync(cancellationToken);
        await _context.SavedVacancies.Where(s => s.UserId == userId).ExecuteDeleteAsync(cancellationToken);

        // Профили каскадно удаляют вакансии, отклики и сообщения чатов (отзывы получат NULL в JobApplicationId)
        await _context.CompanyProfiles.Where(c => c.UserId == userId).ExecuteDeleteAsync(cancellationToken);
        await _context.CandidateProfiles.Where(c => c.UserId == userId).ExecuteDeleteAsync(cancellationToken);
        await _context.Users.Where(u => u.Id == userId).ExecuteDeleteAsync(cancellationToken);

        await transaction.CommitAsync(cancellationToken);

        return fileUrls;
    }

    public async Task AddAsync(User user, CancellationToken cancellationToken)
        => await _context.Users.AddAsync(user, cancellationToken);

    public void Update(User user) => _context.Users.Update(user);
}