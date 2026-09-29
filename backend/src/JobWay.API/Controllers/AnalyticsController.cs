using JobWay.Application.DTOs.Analytics.Response;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/analytics")]
public class AnalyticsController : BaseApiController
{
    private readonly IAnalyticsService _analyticsService;

    public AnalyticsController(IAnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    [HttpGet("employer")]
    [Authorize(Roles = Roles.Employer)]
    public async Task<IActionResult> GetEmployerAnalytics(CancellationToken cancellationToken)
        => HandleError(await _analyticsService.GetEmployerAnalyticsAsync(CurrentUserId, cancellationToken));
}