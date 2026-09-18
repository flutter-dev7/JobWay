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
    public async Task<IActionResult> GetCompanies(CancellationToken cancellationToken)
        => HandleError(await _adminService.GetCompaniesAsync(cancellationToken));

    [HttpPut("companies/{id:guid}/verify")]
    public async Task<IActionResult> VerifyCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.VerifyCompanyAsync(id, cancellationToken));

    [HttpPut("companies/{id:guid}/reject")]
    public async Task<IActionResult> RejectCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.RejectCompanyAsync(id, cancellationToken));

    [HttpGet("users")]
    public async Task<IActionResult> GetUsers(CancellationToken cancellationToken)
        => HandleError(await _adminService.GetUsersAsync(cancellationToken));

    [HttpPut("users/{id:guid}/block")]
    public async Task<IActionResult> BlockUser(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.BlockUserAsync(id, cancellationToken));

    [HttpPut("users/{id:guid}/unblock")]
    public async Task<IActionResult> UnblockUser(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.UnblockUserAsync(id, cancellationToken));

    [HttpPut("vacancies/{id:guid}/archive")]
    public async Task<IActionResult> ArchiveVacancy(Guid id, CancellationToken cancellationToken)
        => HandleError(await _adminService.ArchiveVacancyAsync(id, cancellationToken));
}