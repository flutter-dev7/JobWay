using JobWay.Application.Common;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace JobWay.Infrastructure.BackgroundJobs;

public class VacancyExpiryBackgroundService : BackgroundService
{
    private static readonly TimeSpan CheckInterval = TimeSpan.FromMinutes(1);

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<VacancyExpiryBackgroundService> _logger;

    public VacancyExpiryBackgroundService(IServiceScopeFactory scopeFactory, ILogger<VacancyExpiryBackgroundService> logger)
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
                await ProcessAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Vacancy expiry job failed");
            }

            await Task.Delay(CheckInterval, stoppingToken);
        }
    }

    private async Task ProcessAsync(CancellationToken cancellationToken)
    {
        using var scope = _scopeFactory.CreateScope();
        var unitOfWork = scope.ServiceProvider.GetRequiredService<IUnitOfWork>();
        var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();
        var cacheService = scope.ServiceProvider.GetRequiredService<ICacheService>();

        var now = DateTime.UtcNow;

        // 1. Закрываем вакансии с истёкшим сроком
        var expired = await unitOfWork.Vacancies.GetExpiredAsync(now, cancellationToken);

        foreach (var vacancy in expired)
        {
            vacancy.Status = VacancyStatus.Closed;
            vacancy.FeaturedUntil = null;
            vacancy.ExpiresAt = null;
            unitOfWork.Vacancies.Update(vacancy);
        }

        if (expired.Count > 0)
            await unitOfWork.SaveChangesAsync(cancellationToken);

        foreach (var vacancy in expired)
        {
            var ownerUserId = vacancy.CompanyProfile.UserId;

            await cacheService.RemoveAsync(CacheKeys.Vacancy(vacancy.Id), cancellationToken);
            await cacheService.RemoveAsync(CacheKeys.Subscription(ownerUserId), cancellationToken);
            await cacheService.RemoveAsync(CacheKeys.EmployerAnalytics(vacancy.CompanyProfileId), cancellationToken);

            await notificationService.CreateAsync(
                ownerUserId,
                NotificationType.VacancyExpired,
                "Вакансия закрыта",
                $"Срок публикации вакансии «{vacancy.Title}» истёк. Её можно опубликовать снова.",
                vacancy.Id,
                cancellationToken);
        }

        // 2. Предупреждаем за несколько дней до конца
        var expiring = await unitOfWork.Vacancies.GetExpiringAsync(
            now, now.AddDays(VacancyRules.ExpiryNoticeDays), cancellationToken);

        foreach (var vacancy in expiring)
        {
            vacancy.ExpiryNoticeSent = true;
            unitOfWork.Vacancies.Update(vacancy);
        }

        if (expiring.Count > 0)
            await unitOfWork.SaveChangesAsync(cancellationToken);

        foreach (var vacancy in expiring)
        {
            await notificationService.CreateAsync(
                vacancy.CompanyProfile.UserId,
                NotificationType.VacancyExpiring,
                "Вакансия скоро закроется",
                $"Вакансия «{vacancy.Title}» будет закрыта {vacancy.ExpiresAt:dd.MM.yyyy}. Нажмите «Продлить», чтобы оставить её в ленте.",
                vacancy.Id,
                cancellationToken);
        }
    }
}