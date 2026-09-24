using JobWay.Application.DTOs.CompanyProfile.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Employer)]
[Route("api/company-profile")]
public class CompanyProfileController : BaseApiController
{
    private readonly ICompanyProfileService _companyProfileService;

    public CompanyProfileController(ICompanyProfileService companyProfileService)
    {
        _companyProfileService = companyProfileService;
    }

    [HttpGet("me")]
    public async Task<IActionResult> GetMyProfile(CancellationToken cancellationToken)
        => HandleError(await _companyProfileService.GetMyProfileAsync(CurrentUserId, cancellationToken));

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMyProfile(UpdateCompanyProfileRequest request, CancellationToken cancellationToken)
        => HandleError(await _companyProfileService.UpdateMyProfileAsync(CurrentUserId, request, cancellationToken));

    [HttpPost("me/logo")]
    [RequestSizeLimit(5 * 1024 * 1024)]
    public async Task<IActionResult> UploadLogo(IFormFile file, CancellationToken cancellationToken)
    {
        if (file.Length == 0)
            return BadRequest(new { error = "File is empty" });

        await using var stream = file.OpenReadStream();
        var request = new UploadLogoRequest { FileName = file.FileName, Content = stream };

        return HandleError(await _companyProfileService.UploadLogoAsync(CurrentUserId, request, cancellationToken));
    }
}