namespace JobWay.Application.Interfaces.Services;

public interface IPushNotificationService
{
    Task SendAsync(List<string> deviceTokens, string title, string body, CancellationToken cancellationToken);
}