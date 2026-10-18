using JobWay.Application.Common;
using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.DTOs.Admin.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IAdminService
{
    Task<Result<PagedResult<CompanyModerationResponse>>> GetCompaniesAsync(AdminCompaniesFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<string>> VerifyCompanyAsync(Guid companyId, CancellationToken cancellationToken);
    Task<Result<string>> RejectCompanyAsync(Guid companyId, CancellationToken cancellationToken);
    Task<Result<PagedResult<UserModerationResponse>>> GetUsersAsync(AdminUsersFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<string>> BlockUserAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<string>> UnblockUserAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<string>> ArchiveVacancyAsync(Guid vacancyId, CancellationToken cancellationToken);
}