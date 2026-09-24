using JobWay.Application.DTOs.Notification.Request;
using JobWay.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/notifications")]
public class NotificationController : BaseApiController
{
    private readonly INotificationService _notificationService;

    public NotificationController(INotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
        => HandleError(await _notificationService.GetMyNotificationsAsync(CurrentUserId, cancellationToken));

    [HttpPut("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id, CancellationToken cancellationToken)
        => HandleError(await _notificationService.MarkAsReadAsync(CurrentUserId, id, cancellationToken));

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
        => HandleError(await _notificationService.MarkAllAsReadAsync(CurrentUserId, cancellationToken));
    
    [HttpPost("device-token")]
    public async Task<IActionResult> RegisterDeviceToken(RegisterDeviceTokenRequest request, CancellationToken cancellationToken)
        => HandleError(await _notificationService.RegisterDeviceTokenAsync(CurrentUserId, request, cancellationToken));
}