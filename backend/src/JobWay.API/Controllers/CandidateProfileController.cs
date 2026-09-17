using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Candidate)]
[Route("api/candidate-profile")]
public class CandidateProfileController : BaseApiController
{
    private readonly ICandidateProfileService _candidateProfileService;

    public CandidateProfileController(ICandidateProfileService candidateProfileService)
    {
        _candidateProfileService = candidateProfileService;
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetMyProfile(CancellationToken cancellationToken)
        => HandleError(await _candidateProfileService.GetMyProfileAsync(CurrentUserId, cancellationToken));

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMyProfile(UpdateCandidateProfileRequest request, CancellationToken cancellationToken)
        => HandleError(await _candidateProfileService.UpdateMyProfileAsync(CurrentUserId, request, cancellationToken));
}