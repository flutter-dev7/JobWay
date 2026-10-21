using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Subscription.Response;

public class SubscriptionResponse
{
    public CompanyTier Tier { get; set; }
    public DateTime? TierExpiresAt { get; set; }
    public int ActiveVacanciesCount { get; set; }
    public int ActiveVacanciesLimit { get; set; }
}