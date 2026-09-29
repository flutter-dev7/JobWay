using JobWay.Application.Common;
using JobWay.Application.DTOs.Analytics.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IAnalyticsService
{
    Task<Result<EmployerAnalyticsResponse>> GetEmployerAnalyticsAsync(Guid employerUserId, CancellationToken cancellationToken);
}