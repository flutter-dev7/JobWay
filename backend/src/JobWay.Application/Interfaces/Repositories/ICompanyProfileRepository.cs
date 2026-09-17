using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICompanyProfileRepository
{
    Task<CompanyProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    void Update(CompanyProfile profile);
}