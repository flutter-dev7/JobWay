using JobWay.Application.Common;
using JobWay.Application.DTOs.Notification.Response;
using JobWay.Domain.Enums;

namespace JobWay.Application.Interfaces.Services;

public interface INotificationService
{
    Task<Result<List<NotificationResponse>>> GetMyNotificationsAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<string>> MarkAsReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken);
    Task CreateAsync(Guid userId, NotificationType type, string title, string message, Guid? relatedEntityId, CancellationToken cancellationToken);
}