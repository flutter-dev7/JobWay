using JobWay.Application.Common;
using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.DTOs.JobApplication.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IJobApplicationService
{
    Task<Result<JobApplicationResponse>> ApplyAsync(Guid candidateUserId, Guid vacancyId, CreateJobApplicationRequest request, CancellationToken cancellationToken);
    Task<Result<JobApplicationResponse>> UpdateStatusAsync(Guid employerUserId, Guid applicationId, UpdateJobApplicationStatusRequest request, CancellationToken cancellationToken);
    Task<Result<List<JobApplicationResponse>>> GetByVacancyAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<List<JobApplicationResponse>>> GetMyApplicationsAsync(Guid candidateUserId, CancellationToken cancellationToken);
}