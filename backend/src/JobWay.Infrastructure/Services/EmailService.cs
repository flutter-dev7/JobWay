using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json.Serialization;
using JobWay.Application.Common;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace JobWay.Infrastructure.Services;

public class EmailService : IEmailService
{
    private const string BrevoApiUrl = "https://api.brevo.com/v3/smtp/email";

    private readonly HttpClient _httpClient;
    private readonly EmailSettings _settings;
    private readonly ILogger<EmailService> _logger;

    public EmailService(
        HttpClient httpClient,
        IOptions<EmailSettings> settings,
        ILogger<EmailService> logger)
    {
        _httpClient = httpClient;
        _settings = settings.Value;
        _logger = logger;
    }

    public async Task SendAsync(
        string to,
        string subject,
        string body,
        CancellationToken cancellationToken = default)
    {
        var payload = new BrevoEmailRequest
        {
            Sender = new BrevoSender
            {
                Email = _settings.FromEmail,
                Name = _settings.FromName
            },
            To = new[]
            {
                new BrevoRecipient
                {
                    Email = to
                }
            },
            Subject = subject,
            HtmlContent = body
        };

        using var request = new HttpRequestMessage(
            HttpMethod.Post,
            BrevoApiUrl);

        request.Headers.Add("api-key", _settings.ApiKey);
        request.Headers.Accept.Add(
            new MediaTypeWithQualityHeaderValue("application/json"));

        request.Content = JsonContent.Create(payload);

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            var errorBody = await response.Content.ReadAsStringAsync(
                cancellationToken);

            _logger.LogError(
                "Brevo API вернул ошибку {StatusCode} при отправке письма на {To}: {ErrorBody}",
                response.StatusCode,
                to,
                errorBody);

            throw new InvalidOperationException(
                $"Не удалось отправить письмо через Brevo: {response.StatusCode}");
        }

        _logger.LogInformation(
            "Письмо успешно отправлено через Brevo на {To}",
            to);
    }

    private class BrevoEmailRequest
    {
        [JsonPropertyName("sender")]
        public BrevoSender Sender { get; set; } = new();

        [JsonPropertyName("to")]
        public BrevoRecipient[] To { get; set; } = Array.Empty<BrevoRecipient>();

        [JsonPropertyName("subject")]
        public string Subject { get; set; } = string.Empty;

        [JsonPropertyName("htmlContent")]
        public string HtmlContent { get; set; } = string.Empty;
    }

    private class BrevoSender
    {
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;

        [JsonPropertyName("name")]
        public string Name { get; set; } = string.Empty;
    }

    private class BrevoRecipient
    {
        [JsonPropertyName("email")]
        public string Email { get; set; } = string.Empty;
    }
}