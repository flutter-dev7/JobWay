using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Request;

public class SetCompanyTierRequest
{
    public CompanyTier Tier { get; set; }

    // Для Pro: на сколько дней выдать или продлить. Для Free не используется
    public int Days { get; set; } = 30;
}