using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICandidateProfileRepository
{
    Task<CandidateProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<CandidateProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<List<CandidateProfile>> GetAllAsync(CancellationToken cancellationToken);
    Task<List<CandidateProfile>> GetAllWithSkillsAsync(CancellationToken cancellationToken);
    Task<(List<CandidateSearchItem> Items, int TotalCount)> SearchForEmployerAsync(CandidateSearchRequest filter, CancellationToken cancellationToken);
    void Update(CandidateProfile profile);
}