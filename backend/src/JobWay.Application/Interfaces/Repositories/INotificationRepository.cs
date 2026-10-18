using JobWay.Application.DTOs.Notification.Request;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Interfaces.Repositories;

public interface INotificationRepository
{
    Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<List<Notification>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<(List<Notification> Items, int TotalCount)> GetPagedByUserIdAsync(Guid userId, NotificationFilterRequest filter, CancellationToken cancellationToken);
    Task<int> CountUnreadAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<Notification>> GetUnreadByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<HashSet<Guid>> GetNotifiedRelatedEntityIdsAsync(Guid userId, NotificationType type, List<Guid> relatedEntityIds, CancellationToken cancellationToken);
    void Add(Notification notification);
    void Update(Notification notification);
}