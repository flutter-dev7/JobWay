using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICandidateProfileRepository
{
    Task<CandidateProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<CandidateProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<List<CandidateProfile>> GetAllAsync(CancellationToken cancellationToken);
    void Update(CandidateProfile profile);
}