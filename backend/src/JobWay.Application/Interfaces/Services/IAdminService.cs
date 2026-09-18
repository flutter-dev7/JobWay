using JobWay.Application.Common;
using JobWay.Application.DTOs.Admin.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IAdminService
{
    Task<Result<List<CompanyModerationResponse>>> GetCompaniesAsync(CancellationToken cancellationToken);
    Task<Result<string>> VerifyCompanyAsync(Guid companyId, CancellationToken cancellationToken);
    Task<Result<string>> RejectCompanyAsync(Guid companyId, CancellationToken cancellationToken);
    Task<Result<List<UserModerationResponse>>> GetUsersAsync(CancellationToken cancellationToken);
    Task<Result<string>> BlockUserAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<string>> UnblockUserAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<string>> ArchiveVacancyAsync(Guid vacancyId, CancellationToken cancellationToken);
}