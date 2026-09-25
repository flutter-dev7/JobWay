using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Net.Mail;
using System.Text.Json.Serialization;
using JobWay.Application.Common;
using JobWay.Application.Interfaces;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace JobWay.Infrastructure.Services;

public class EmailService : IEmailService
{
    private const string ResendApiUrl = "https://api.resend.com/emails";
 
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
 
        _httpClient.BaseAddress ??= new Uri(ResendApiUrl);
        _httpClient.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", _settings.ApiKey);
    }
 
    public async Task SendAsync(string to, string subject, string body, CancellationToken cancellationToken = default)
    {
        var payload = new ResendEmailRequest
        {
            From = $"{_settings.FromName} <{_settings.FromEmail}>",
            To = new[] { to },
            Subject = subject,
            Html = body
        };
 
        using var response = await _httpClient.PostAsJsonAsync(ResendApiUrl, payload, cancellationToken);
 
        if (!response.IsSuccessStatusCode)
        {
            var errorBody = await response.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogError(
                "Resend API вернул ошибку {StatusCode} при отправке письма на {To}: {ErrorBody}",
                response.StatusCode, to, errorBody);
 
            throw new InvalidOperationException($"Не удалось отправить письмо через Resend: {response.StatusCode}");
        }
    }
 
    private class ResendEmailRequest
    {
        [JsonPropertyName("from")]
        public string From { get; set; } = string.Empty;
 
        [JsonPropertyName("to")]
        public string[] To { get; set; } = Array.Empty<string>();
 
        [JsonPropertyName("subject")]
        public string Subject { get; set; } = string.Empty;
 
        [JsonPropertyName("html")]
        public string Html { get; set; } = string.Empty;
    }
}
   