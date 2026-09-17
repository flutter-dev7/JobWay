using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICandidateProfileRepository
{
    Task<CandidateProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    void Update(CandidateProfile profile);
}