using JobWay.Application.Common;
using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ISearchService
{
    Task<Result<PagedResult<CompanySearchItem>>> SearchCompaniesAsync(CompanySearchRequest filter, CancellationToken cancellationToken);
    Task<Result<PagedResult<CandidateSearchItem>>> SearchCandidatesAsync(Guid employerUserId, CandidateSearchRequest filter, CancellationToken cancellationToken);
}