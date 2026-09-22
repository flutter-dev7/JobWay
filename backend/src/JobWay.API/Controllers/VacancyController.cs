using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/vacancies")]
public class VacancyController : BaseApiController
{
    private readonly IVacancyService _vacancyService;
    private readonly ISavedVacancyService _savedVacancyService;

    public VacancyController(IVacancyService vacancyService, ISavedVacancyService savedVacancyService)
    {
        _vacancyService = vacancyService;
        _savedVacancyService = savedVacancyService;
    }

    [HttpGet]
    public async Task<IActionResult> GetActive([FromQuery] VacancyFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.GetActiveAsync(filter, cancellationToken));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.GetByIdAsync(id, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpGet("my")]
    public async Task<IActionResult> GetMyVacancies(CancellationToken cancellationToken)
        => HandleError(await _vacancyService.GetMyVacanciesAsync(CurrentUserId, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpPost]
    public async Task<IActionResult> Create(CreateVacancyRequest request, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.CreateAsync(CurrentUserId, request, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpPut("{id:guid}")]
    public async Task<IActionResult> Update(Guid id, UpdateVacancyRequest request, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.UpdateAsync(CurrentUserId, id, request, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpPost("{id:guid}/publish")]
    public async Task<IActionResult> Publish(Guid id, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.PublishAsync(CurrentUserId, id, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpPost("{id:guid}/close")]
    public async Task<IActionResult> Close(Guid id, CancellationToken cancellationToken)
        => HandleError(await _vacancyService.CloseAsync(CurrentUserId, id, cancellationToken));
    
    [HttpGet("today-count")]
    public async Task<IActionResult> GetTodayCount(CancellationToken cancellationToken)
        => HandleError(await _vacancyService.GetTodayCountAsync(cancellationToken));
    
    [Authorize(Roles = Roles.Candidate)]
    [HttpPost("{id:guid}/save")]
    public async Task<IActionResult> Save(Guid id, CancellationToken cancellationToken)
        => HandleError(await _savedVacancyService.SaveAsync(CurrentUserId, id, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpDelete("{id:guid}/save")]
    public async Task<IActionResult> Unsave(Guid id, CancellationToken cancellationToken)
        => HandleError(await _savedVacancyService.UnsaveAsync(CurrentUserId, id, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpGet("saved")]
    public async Task<IActionResult> GetSaved(CancellationToken cancellationToken)
        => HandleError(await _savedVacancyService.GetSavedAsync(CurrentUserId, cancellationToken));
}