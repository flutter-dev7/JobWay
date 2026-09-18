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
}