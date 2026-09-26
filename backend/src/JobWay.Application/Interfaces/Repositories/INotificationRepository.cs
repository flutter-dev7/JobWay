using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Interfaces.Repositories;

public interface INotificationRepository
{
    Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<List<Notification>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<Notification>> GetUnreadByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<HashSet<Guid>> GetNotifiedRelatedEntityIdsAsync(Guid userId, NotificationType type, List<Guid> relatedEntityIds, CancellationToken cancellationToken);
    void Add(Notification notification);
    void Update(Notification notification);
}