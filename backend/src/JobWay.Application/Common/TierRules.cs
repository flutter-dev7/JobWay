using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Common;

public static class TierRules
{
    public const int FreeActiveVacancyLimit = 3;
    public const int ProActiveVacancyLimit = 10;

    // Самостоятельное продвижение в топ: только Pro
    public const int ProPromotionsPerMonth = 2;
    public const int PromotionDays = 7;

    // Pro, пока не истёк срок. Фоновая задача для сброса не нужна: тариф считается при чтении
    public static CompanyTier GetEffectiveTier(CompanyProfile company)
        => company.Tier == CompanyTier.Pro
           && company.TierExpiresAt is { } expiresAt
           && expiresAt > DateTime.UtcNow
            ? CompanyTier.Pro
            : CompanyTier.Free;

    public static int GetActiveVacancyLimit(CompanyProfile company)
        => GetEffectiveTier(company) == CompanyTier.Pro ? ProActiveVacancyLimit : FreeActiveVacancyLimit;

    public static int GetMonthlyPromotionLimit(CompanyProfile company)
        => GetEffectiveTier(company) == CompanyTier.Pro ? ProPromotionsPerMonth : 0;

    public static DateTime CurrentMonthStartUtc()
    {
        var now = DateTime.UtcNow;
        return new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc);
    }
}