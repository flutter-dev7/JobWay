using JobWay.Application.Common;
using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.DTOs.JobApplication.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IJobApplicationService
{
    Task<Result<JobApplicationResponse>> ApplyAsync(Guid candidateUserId, Guid vacancyId, CreateJobApplicationRequest request, CancellationToken cancellationToken);
    Task<Result<JobApplicationResponse>> UpdateStatusAsync(Guid employerUserId, Guid applicationId, UpdateJobApplicationStatusRequest request, CancellationToken cancellationToken);
    Task<Result<PagedResult<JobApplicationResponse>>> GetByVacancyAsync(Guid employerUserId, Guid vacancyId, ApplicationFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<PagedResult<JobApplicationResponse>>> GetMyApplicationsAsync(Guid candidateUserId, ApplicationFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<List<Guid>>> GetMyAppliedVacancyIdsAsync(Guid candidateUserId, CancellationToken cancellationToken);
}