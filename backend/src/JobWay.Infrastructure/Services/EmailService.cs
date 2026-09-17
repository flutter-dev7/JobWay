// Infrastructure/Services/EmailService.cs
using System.Net;
using System.Net.Mail;
using JobWay.Application.Common;
using JobWay.Application.Interfaces;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Options;

namespace JobWay.Infrastructure.Services;

public class EmailService : IEmailService
{
    private readonly EmailSettings _settings;

    public EmailService(IOptions<EmailSettings> settings)
    {
        _settings = settings.Value;
    }

    public async Task SendAsync(string to, string subject, string body, CancellationToken cancellationToken)
    {
        using var client = new SmtpClient(_settings.Host, _settings.Port)
        {
            Credentials = new NetworkCredential(_settings.UserName, _settings.Password),
            EnableSsl = true
        };

        var message = new MailMessage(
            new MailAddress(_settings.FromEmail, _settings.FromName),
            new MailAddress(to))
        {
            Subject = subject,
            Body = body,
            IsBodyHtml = true
        };

        await client.SendMailAsync(message, cancellationToken);
    }
}