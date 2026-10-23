using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ICompanyProfileRepository
{
    Task<CompanyProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<CompanyProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    Task<List<CompanyProfile>> GetAllAsync(CancellationToken cancellationToken);
    Task<(List<CompanyProfile> Items, int TotalCount)> GetPagedForAdminAsync(AdminCompaniesFilterRequest filter, CancellationToken cancellationToken);
    Task<(List<CompanySearchItem> Items, int TotalCount)> SearchPublicAsync(CompanySearchRequest filter, CancellationToken cancellationToken);
    Task<CompanyProfile?> GetPublicByIdAsync(Guid id, CancellationToken cancellationToken);
    void Update(CompanyProfile profile);
}