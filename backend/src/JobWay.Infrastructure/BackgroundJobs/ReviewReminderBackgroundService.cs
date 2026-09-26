using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace JobWay.Infrastructure.BackgroundJobs;

public class ReviewReminderBackgroundService : BackgroundService
{
    private static readonly TimeSpan CheckInterval = TimeSpan.FromHours(24);
    private static readonly TimeSpan ReminderDelay = TimeSpan.FromDays(2);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<ReviewReminderBackgroundService> _logger;

    public ReviewReminderBackgroundService(IServiceScopeFactory scopeFactory, ILogger<ReviewReminderBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await SendRemindersAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Review reminder job failed");
            }

            await Task.Delay(CheckInterval, stoppingToken);
        }
    }

    private async Task SendRemindersAsync(CancellationToken cancellationToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

        var threshold = DateTime.UtcNow - ReminderDelay;
        var applications = await unitOfWork.JobApplications.GetCompletedWithoutReminderCheckAsync(threshold, cancellationToken);

        if (applications.Count == 0) return;

        var applicationIds = applications.Select(a => a.Id).ToList();

        var candidateReviewed = await unitOfWork.Reviews.GetReviewedApplicationIdsAsync(applicationIds, ReviewType.CandidateToCompany, cancellationToken);
        var companyReviewed = await unitOfWork.Reviews.GetReviewedApplicationIdsAsync(applicationIds, ReviewType.CompanyToCandidate, cancellationToken);

        foreach (var application in applications)
        {
            var candidateUserId = application.CandidateProfile.UserId;
            var companyUserId = application.Vacancy.CompanyProfile.UserId;

            if (!candidateReviewed.Contains(application.Id))
                await TryRemindAsync(unitOfWork, notificationService, candidateUserId, application.Id,
                    $"Как прошло с «{application.Vacancy.CompanyProfile.CompanyName}»? Оставьте отзыв о компании.", cancellationToken);

            if (!companyReviewed.Contains(application.Id))
                await TryRemindAsync(unitOfWork, notificationService, companyUserId, application.Id,
                    $"Оцените кандидата {application.CandidateProfile.FullName} по отклику на «{application.Vacancy.Title}».", cancellationToken);
        }
    }

    private static async Task TryRemindAsync(
        IUnitOfWork unitOfWork,
        INotificationService notificationService,
        Guid userId,
        Guid applicationId,
        string message,
        CancellationToken cancellationToken)
    {
        var alreadyNotified = await unitOfWork.Notifications.GetNotifiedRelatedEntityIdsAsync(
            userId, NotificationType.ReviewReminder, [applicationId], cancellationToken);

        if (alreadyNotified.Contains(applicationId)) return;

        await notificationService.CreateAsync(
            userId,
            NotificationType.ReviewReminder,
            "Не забудьте оставить отзыв",
            message,
            applicationId,
            cancellationToken);
    }
}