using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Subscription.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SubscriptionService : ISubscriptionService
{
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(2);

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;

    public SubscriptionService(IUnitOfWork unitOfWork, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
    }

    public async Task<Result<SubscriptionResponse>> GetMyAsync(Guid employerUserId, CancellationToken cancellationToken)
    {
        var cacheKey = CacheKeys.Subscription(employerUserId);

        var cached = await _cacheService.GetAsync(cacheKey, cancellationToken);
        if (cached is not null)
        {
            var cachedResponse = JsonSerializer.Deserialize<SubscriptionResponse>(cached);

            // Pro с истёкшим сроком из кэша не берём
            var expired = cachedResponse is { Tier: CompanyTier.Pro }
                          && (cachedResponse.TierExpiresAt is null || cachedResponse.TierExpiresAt <= DateTime.UtcNow);

            if (cachedResponse is not null && !expired)
                return Result<SubscriptionResponse>.Ok(cachedResponse);
        }

        var company = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (company is null)
            return Result<SubscriptionResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var tier = TierRules.GetEffectiveTier(company);
        var activeCount = await _unitOfWork.Vacancies.CountActiveByCompanyProfileIdAsync(company.Id, cancellationToken);
        var promotionsUsed = await _unitOfWork.Vacancies.CountPromotionsSinceAsync(company.Id, TierRules.CurrentMonthStartUtc(), cancellationToken);
        var invitationsUsed = await _unitOfWork.Invitations.CountCreatedSinceAsync(company.Id, TierRules.TodayStartUtc(), cancellationToken);
        var response = new SubscriptionResponse
        {
            Tier = tier,
            TierExpiresAt = tier == CompanyTier.Pro ? company.TierExpiresAt : null,
            ActiveVacanciesCount = activeCount,
            ActiveVacanciesLimit = TierRules.GetActiveVacancyLimit(company),
            PromotionsUsed = promotionsUsed,
            PromotionsLimit = TierRules.GetMonthlyPromotionLimit(company),
            PromotionDays = TierRules.PromotionDays,
            InvitationsUsed = invitationsUsed,
            InvitationsLimit = TierRules.GetDailyInvitationLimit(company)
            
        };

        await _cacheService.SetAsync(cacheKey, JsonSerializer.Serialize(response), CacheDuration, cancellationToken);

        return Result<SubscriptionResponse>.Ok(response);
    }
}