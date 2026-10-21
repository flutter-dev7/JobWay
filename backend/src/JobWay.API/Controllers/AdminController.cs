using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Admin)]
[Route("api/admin")]
public class AdminController : BaseApiController
{
    private readonly IAdminService _adminService;

    public AdminController(IAdminService adminService)
    {
        _adminService = adminService;
    }
    
    [HttpGet("companies")]
    public async Task<IActionResult> GetCompanies([FromQuery] AdminCompaniesFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _adminService.GetCompaniesAsync(filter, cancellationToken));

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers([FromQuery] AdminUsersFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _adminService.GetUsersAsync(filter, cancellationToken));

    [HttpPut("companies/{id:guid}/verify")]
    public async Task<IActionResult> VerifyCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.VerifyCompanyAsync(id, cancellationToken));

    [HttpPut("companies/{id:guid}/reject")]
    public async Task<IActionResult> RejectCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.RejectCompanyAsync(id, cancellationToken));

    [HttpPut("users/{id:guid}/block")]
    public async Task<IActionResult> BlockUser(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.BlockUserAsync(id, cancellationToken));

    [HttpPut("users/{id:guid}/unblock")]
    public async Task<IActionResult> UnblockUser(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.UnblockUserAsync(id, cancellationToken));

    [HttpPut("vacancies/{id:guid}/archive")]
    public async Task<IActionResult> ArchiveVacancy(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.ArchiveVacancyAsync(id, cancellationToken));
    
    [HttpPut("companies/{id:guid}/tier")]
    public async Task<IActionResult> SetCompanyTier(Guid id, SetCompanyTierRequest request, CancellationToken cancellationToken)
        => HandleError(await _adminService.SetCompanyTierAsync(id, request, cancellationToken));

    [HttpPut("vacancies/{id:guid}/feature")]
    public async Task<IActionResult> FeatureVacancy(Guid id, FeatureVacancyRequest request, CancellationToken cancellationToken)
        => HandleError(await _adminService.FeatureVacancyAsync(id, request, cancellationToken));
    
    [HttpGet("companies/{id:guid}/vacancies")]
    public async Task<IActionResult> GetCompanyActiveVacancies(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.GetCompanyActiveVacanciesAsync(id, cancellationToken));
    
    [HttpGet("companies/{id:guid}")]
    public async Task<IActionResult> GetCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.GetCompanyAsync(id, cancellationToken));
}