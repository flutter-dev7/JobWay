using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Candidate)]
[Route("api/candidate-profile/me/visibility")]
public class CandidateVisibilityController : BaseApiController
{
    private readonly ICandidateProfileService _candidateProfileService;

    public CandidateVisibilityController(ICandidateProfileService candidateProfileService)
    {
        _candidateProfileService = candidateProfileService;
    }

    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
        => HandleError(await _candidateProfileService.GetVisibilityAsync(CurrentUserId, cancellationToken));

    [HttpPut]
    public async Task<IActionResult> Set(SetVisibilityRequest request, CancellationToken cancellationToken)
        => HandleError(await _candidateProfileService.SetVisibilityAsync(CurrentUserId, request.IsVisible, cancellationToken));
}