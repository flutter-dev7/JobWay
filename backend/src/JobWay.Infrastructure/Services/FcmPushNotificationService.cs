using FirebaseAdmin.Messaging;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;

namespace JobWay.Infrastructure.Services;

public class FcmPushNotificationService : IPushNotificationService
{
    private readonly ILogger<FcmPushNotificationService> _logger;

    public FcmPushNotificationService(ILogger<FcmPushNotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendAsync(List<string> deviceTokens, string title, string body, CancellationToken cancellationToken)
    {
        if (deviceTokens.Count == 0) return;

        var message = new MulticastMessage
        {
            Tokens = deviceTokens,
            Notification = new Notification { Title = title, Body = body }
        };

        try
        {
            await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message, cancellationToken);
        }
        catch (Exception ex)
        {
            // push — best-effort, не должен ронять основную логику (создание Notification в БД)
            _logger.LogError(ex, "Failed to send push notification");
        }
    }
}