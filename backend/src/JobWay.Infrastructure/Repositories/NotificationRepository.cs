using JobWay.Application.DTOs.Notification.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly AppDbContext _context;

    public NotificationRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.Notifications.FirstOrDefaultAsync(n => n.Id == id, cancellationToken);

    public Task<List<Notification>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<List<Notification>> GetUnreadByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync(cancellationToken);
    
    public async Task<HashSet<Guid>> GetNotifiedRelatedEntityIdsAsync(Guid userId, NotificationType type, List<Guid> relatedEntityIds, CancellationToken cancellationToken)
    {
        var ids = await _context.Notifications
            .Where(n => n.UserId == userId && n.Type == type && n.RelatedEntityId != null && relatedEntityIds.Contains(n.RelatedEntityId.Value))
            .Select(n => n.RelatedEntityId!.Value)
            .ToListAsync(cancellationToken);

        return ids.ToHashSet();
    }
    
    public async Task<(List<Notification> Items, int TotalCount)> GetPagedByUserIdAsync(
        Guid userId, NotificationFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.Notifications.Where(n => n.UserId == userId);

        var types = filter.Types;
        if (types is { Count: > 0 })
            query = query.Where(n => types.Contains(n.Type));

        if (filter.UnreadOnly)
            query = query.Where(n => !n.IsRead);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(n => n.CreatedAt)
            .ThenBy(n => n.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public Task<int> CountUnreadAsync(Guid userId, CancellationToken cancellationToken)
        => _context.Notifications.CountAsync(n => n.UserId == userId && !n.IsRead, cancellationToken);

    public void Add(Notification notification) => _context.Notifications.Add(notification);
    public void Update(Notification notification) => _context.Notifications.Update(notification);
}