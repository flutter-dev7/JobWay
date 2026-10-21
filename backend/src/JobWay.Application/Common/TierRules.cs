using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Common;

public static class TierRules
{
    public const int FreeActiveVacancyLimit = 3;
    public const int ProActiveVacancyLimit = 10;

    // Pro, пока не истёк срок. Фоновая задача для сброса не нужна: тариф считается при чтении
    public static CompanyTier GetEffectiveTier(CompanyProfile company)
        => company.Tier == CompanyTier.Pro
           && company.TierExpiresAt is { } expiresAt
           && expiresAt > DateTime.UtcNow
            ? CompanyTier.Pro
            : CompanyTier.Free;

    public static int GetActiveVacancyLimit(CompanyProfile company)
        => GetEffectiveTier(company) == CompanyTier.Pro ? ProActiveVacancyLimit : FreeActiveVacancyLimit;
}