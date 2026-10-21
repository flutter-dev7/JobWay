using JobWay.Application.Common;
using JobWay.Application.DTOs.Subscription.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SubscriptionService : ISubscriptionService
{
    private readonly IUnitOfWork _unitOfWork;

    public SubscriptionService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<SubscriptionResponse>> GetMyAsync(Guid employerUserId, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (company is null)
            return Result<SubscriptionResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var tier = TierRules.GetEffectiveTier(company);
        var activeCount = await _unitOfWork.Vacancies.CountActiveByCompanyProfileIdAsync(company.Id, cancellationToken);

        return Result<SubscriptionResponse>.Ok(new SubscriptionResponse
        {
            Tier = tier,
            TierExpiresAt = tier == CompanyTier.Pro ? company.TierExpiresAt : null,
            ActiveVacanciesCount = activeCount,
            ActiveVacanciesLimit = TierRules.GetActiveVacancyLimit(company)
        });
    }
}