using JobWay.Application.Common;
using JobWay.Application.DTOs.Subscription.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ISubscriptionService
{
    Task<Result<SubscriptionResponse>> GetMyAsync(Guid employerUserId, CancellationToken cancellationToken);
}