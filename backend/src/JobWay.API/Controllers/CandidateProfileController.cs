using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
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

    [HttpPost("me/resume")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<IActionResult> UploadResume(IFormFile file, CancellationToken cancellationToken)
    {
        if (file.Length == 0)
            return BadRequest(new { error = "File is empty" });

        await using var stream = file.OpenReadStream();
        var request = new UploadResumeRequest { FileName = file.FileName, Content = stream };

        return HandleError(await _candidateProfileService.UploadResumeAsync(CurrentUserId, request, cancellationToken));
    }

    [HttpPost("me/photo")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<IActionResult> UploadPhoto(IFormFile file, CancellationToken cancellationToken)
    {
        if (file.Length == 0)
            return BadRequest(new { error = "File is empty" });

        await using var stream = file.OpenReadStream();
        var request = new UploadPhotoRequest { FileName = file.FileName, Content = stream };

        return HandleError(await _candidateProfileService.UploadPhotoAsync(CurrentUserId, request, cancellationToken));
    }
}