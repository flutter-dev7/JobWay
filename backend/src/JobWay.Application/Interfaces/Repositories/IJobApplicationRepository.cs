using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IJobApplicationRepository
{
    Task<JobApplication?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<bool> ExistsAsync(Guid candidateProfileId, Guid vacancyId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByVacancyIdAsync(Guid vacancyId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByCandidateProfileIdAsync(Guid candidateProfileId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByCompanyProfileIdAsync(Guid companyProfileId, CancellationToken cancellationToken);
    Task<bool> ExistsForCandidateAndCompanyAsync(Guid candidateProfileId, Guid companyProfileId, CancellationToken cancellationToken);
    Task<JobApplication?> GetWithParticipantsAsync(Guid id, CancellationToken cancellationToken);
    Task<(List<JobApplication> Items, int TotalCount)> GetPagedByCandidateProfileIdAsync(Guid candidateProfileId, ApplicationFilterRequest filter, CancellationToken cancellationToken);
    Task<(List<JobApplication> Items, int TotalCount)> GetPagedByVacancyIdAsync(Guid vacancyId, ApplicationFilterRequest filter, CancellationToken cancellationToken);
    Task<List<Guid>> GetVacancyIdsByCandidateProfileIdAsync(Guid candidateProfileId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByIdsWithParticipantsAsync(List<Guid> ids, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetCompletedWithoutReminderCheckAsync(DateTime updatedBefore, CancellationToken cancellationToken);
    void Add(JobApplication application);
    void Update(JobApplication application);
}