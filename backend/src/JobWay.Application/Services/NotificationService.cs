using JobWay.Application.Common;
using JobWay.Application.DTOs.Notification.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class NotificationService : INotificationService
{
    private readonly IUnitOfWork _unitOfWork;

    public NotificationService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<List<NotificationResponse>>> GetMyNotificationsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var notifications = await _unitOfWork.Notifications.GetByUserIdAsync(userId, cancellationToken);
        return Result<List<NotificationResponse>>.Ok(notifications.Select(MapToResponse).ToList());
    }

    public async Task<Result<string>> MarkAsReadAsync(Guid userId, Guid notificationId, CancellationToken cancellationToken)
    {
        var notification = await _unitOfWork.Notifications.GetByIdAsync(notificationId, cancellationToken);

        if (notification is null || notification.UserId != userId)
            return Result<string>.Fail("Notification not found", ErrorType.NotFound);

        notification.IsRead = true;

        _unitOfWork.Notifications.Update(notification);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("Notification marked as read");
    }

    public async Task CreateAsync(Guid userId, NotificationType type, string title, string message, Guid? relatedEntityId, CancellationToken cancellationToken)
    {
        var notification = new Notification
        {
            UserId = userId,
            Type = type,
            Title = title,
            Message = message,
            RelatedEntityId = relatedEntityId
        };

        _unitOfWork.Notifications.Add(notification);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private static NotificationResponse MapToResponse(Notification notification) => new()
    {
        Id = notification.Id,
        Type = notification.Type,
        Title = notification.Title,
        Message = notification.Message,
        IsRead = notification.IsRead,
        RelatedEntityId = notification.RelatedEntityId,
        CreatedAt = notification.CreatedAt
    };
}