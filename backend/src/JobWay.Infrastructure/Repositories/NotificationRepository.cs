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

    public void Add(Notification notification) => _context.Notifications.Add(notification);
    public void Update(Notification notification) => _context.Notifications.Update(notification);
}