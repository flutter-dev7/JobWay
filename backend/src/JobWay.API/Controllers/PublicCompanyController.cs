using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Authorize(Roles = Roles.Candidate)]
[Route("api/companies")]
public class PublicCompanyController : BaseApiController
{
    private readonly ICompanyProfileService _companyProfileService;
    private readonly IVacancyService _vacancyService;

    public PublicCompanyController(ICompanyProfileService companyProfileService, IVacancyService vacancyService)
    {
        _companyProfileService = companyProfileService;
        _vacancyService = vacancyService;
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetCompany(Guid id, CancellationToken cancellationToken)
        => HandleError(await _companyProfileService.GetPublicProfileAsync(id, cancellationToken));

    [HttpGet("{id:guid}/vacancies")]
    public async Task<IActionResult> GetVacancies(Guid id, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.GetPublicCompanyVacanciesAsync(id, cancellationToken));
}