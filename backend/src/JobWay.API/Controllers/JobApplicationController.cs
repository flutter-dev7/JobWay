using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api")]
public class JobApplicationController : BaseApiController
{
    private readonly IJobApplicationService _jobApplicationService;

    public JobApplicationController(IJobApplicationService jobApplicationService)
    {
        _jobApplicationService = jobApplicationService;
    }

    [Authorize(Roles = Roles.Candidate)]
    [HttpPost("vacancies/{vacancyId:guid}/applications")]
    public async Task<IActionResult> Apply(Guid vacancyId, CreateJobApplicationRequest request, CancellationToken cancellationToken)
        => HandleError(await _jobApplicationService.ApplyAsync(CurrentUserId, vacancyId, request, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpGet("vacancies/{vacancyId:guid}/applications")]
    public async Task<IActionResult> GetByVacancy(Guid vacancyId, CancellationToken cancellationToken)
        => HandleError(await _jobApplicationService.GetByVacancyAsync(CurrentUserId, vacancyId, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpGet("applications/my")]
    public async Task<IActionResult> GetMyApplications(CancellationToken cancellationToken)
        => HandleError(await _jobApplicationService.GetMyApplicationsAsync(CurrentUserId, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpPut("applications/{applicationId:guid}/status")]
    public async Task<IActionResult> UpdateStatus(Guid applicationId, UpdateJobApplicationStatusRequest request, CancellationToken cancellationToken)
        => HandleError(await _jobApplicationService.UpdateStatusAsync(CurrentUserId, applicationId, request, cancellationToken));
}