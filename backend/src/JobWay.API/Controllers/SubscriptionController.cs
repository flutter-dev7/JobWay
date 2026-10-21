using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Employer)]
[Route("api/subscription")]
public class SubscriptionController : BaseApiController
{
    private readonly ISubscriptionService _subscriptionService;

    public SubscriptionController(ISubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    [HttpGet("my")]
    public async Task<IActionResult> GetMy(CancellationToken cancellationToken)
        => HandleError(await _subscriptionService.GetMyAsync(CurrentUserId, cancellationToken));
}