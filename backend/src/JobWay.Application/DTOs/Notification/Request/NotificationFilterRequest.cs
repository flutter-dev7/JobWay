using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Notification.Request;

public class NotificationFilterRequest
{
    public List<NotificationType>? Types { get; set; }
    public bool UnreadOnly { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}