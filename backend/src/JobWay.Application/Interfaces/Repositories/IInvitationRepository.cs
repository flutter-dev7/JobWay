using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IInvitationRepository
{
    Task<Invitation?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<bool> ExistsAsync(Guid candidateProfileId, Guid vacancyId, CancellationToken cancellationToken);
    Task<int> CountCreatedSinceAsync(Guid companyProfileId, DateTime since, CancellationToken cancellationToken);
    Task<(List<Invitation> Items, int TotalCount)> GetPagedByCandidateProfileIdAsync(
        Guid candidateProfileId, InvitationFilterRequest filter, CancellationToken cancellationToken);
    Task<List<Invitation>> GetByCandidateAndCompanyAsync(Guid candidateProfileId, Guid companyProfileId, CancellationToken cancellationToken);
    void Add(Invitation invitation);
    void Update(Invitation invitation);
}