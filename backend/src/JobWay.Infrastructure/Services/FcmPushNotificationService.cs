using FirebaseAdmin.Messaging;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;

namespace JobWay.Infrastructure.Services;

public class FcmPushNotificationService : IPushNotificationService
{
    private const string AndroidChannelId = "jobway_messages";

    private readonly ILogger<FcmPushNotificationService> _logger;

    public FcmPushNotificationService(ILogger<FcmPushNotificationService> logger)
    {
        _logger = logger;
    }

    public async Task SendAsync(List<string> deviceTokens, string title, string body, CancellationToken cancellationToken)
    {
        if (deviceTokens.Count == 0)
        {
            _logger.LogInformation("Push skipped: recipient has no registered device tokens");
            return;
        }

        var message = new MulticastMessage
        {
            Tokens = deviceTokens,
            Notification = new Notification { Title = title, Body = body },
            Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification
                {
                    ChannelId = AndroidChannelId,
                    Sound = "default"
                }
            }
        };

        try
        {
            var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message, cancellationToken);

            _logger.LogInformation("Push sent: {Success}/{Total}", response.SuccessCount, deviceTokens.Count);

            for (var i = 0; i < response.Responses.Count; i++)
            {
                var item = response.Responses[i];
                if (item.IsSuccess) continue;

                var token = deviceTokens[i];
                _logger.LogWarning(
                    "Push to token ...{TokenTail} failed: {ErrorCode} / {MessagingErrorCode}: {Message}",
                    token.Length > 6 ? token[^6..] : token,
                    item.Exception?.ErrorCode,
                    item.Exception?.MessagingErrorCode,
                    item.Exception?.Message);
            }
        }
        catch (Exception ex)
        {
            // push — best-effort, не должен ронять основную логику (создание Notification в БД)
            _logger.LogError(ex, "Failed to send push notification");
        }
    }
}