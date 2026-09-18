using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICompanyProfileRepository
{
    Task<CompanyProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<CompanyProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<CompanyProfile>> GetAllAsync(CancellationToken cancellationToken);
    void Update(CompanyProfile profile);
}