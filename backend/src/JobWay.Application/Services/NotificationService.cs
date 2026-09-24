using JobWay.Application.Common;
using JobWay.Application.DTOs.Notification.Request;
using JobWay.Application.DTOs.Notification.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class NotificationService : INotificationService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPushNotificationService _pushNotificationService;

    public NotificationService(IUnitOfWork unitOfWork,  IPushNotificationService pushNotificationService)
    {
        _unitOfWork = unitOfWork;
        _pushNotificationService = pushNotificationService;
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
    
    public async Task<Result<string>> MarkAllAsReadAsync(Guid userId, CancellationToken cancellationToken)
    {
        var unread = await _unitOfWork.Notifications.GetUnreadByUserIdAsync(userId, cancellationToken);

        foreach (var notification in unread)
        {
            notification.IsRead = true;
            _unitOfWork.Notifications.Update(notification);
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("All notifications marked as read");
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

        var deviceTokens = await _unitOfWork.DeviceTokens.GetTokensByUserIdAsync(userId, cancellationToken);
        await _pushNotificationService.SendAsync(deviceTokens, title, message, cancellationToken);
    }
    
    public async Task<Result<string>> RegisterDeviceTokenAsync(Guid userId, RegisterDeviceTokenRequest request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.DeviceTokens.GetByTokenAsync(request.Token, cancellationToken);

        if (existing is not null)
        {
            existing.UserId = userId;
            _unitOfWork.DeviceTokens.Update(existing);
        }
        else
        {
            _unitOfWork.DeviceTokens.Add(new DeviceToken { UserId = userId, Token = request.Token, Platform = request.Platform });
        }

        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return Result<string>.Ok("Device token registered");
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