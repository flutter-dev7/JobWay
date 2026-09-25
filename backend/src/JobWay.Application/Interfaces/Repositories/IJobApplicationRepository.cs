using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IJobApplicationRepository
{
    Task<JobApplication?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<bool> ExistsAsync(Guid candidateProfileId, Guid vacancyId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByVacancyIdAsync(Guid vacancyId, CancellationToken cancellationToken);
    Task<List<JobApplication>> GetByCandidateProfileIdAsync(Guid candidateProfileId, CancellationToken cancellationToken);
    Task<bool> ExistsForCandidateAndCompanyAsync(Guid candidateProfileId, Guid companyProfileId, CancellationToken cancellationToken);
    void Add(JobApplication application);
    void Update(JobApplication application);
}