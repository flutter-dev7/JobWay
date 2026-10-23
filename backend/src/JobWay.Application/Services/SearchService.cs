using JobWay.Application.Common;
using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SearchService : ISearchService
{
    private readonly IUnitOfWork _unitOfWork;

    public SearchService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<PagedResult<CompanySearchItem>>> SearchCompaniesAsync(CompanySearchRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (items, totalCount) = await _unitOfWork.CompanyProfiles.SearchPublicAsync(filter, cancellationToken);

        return Result<PagedResult<CompanySearchItem>>.Ok(new PagedResult<CompanySearchItem>
        {
            Items = items,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }

    public async Task<Result<PagedResult<CandidateSearchItem>>> SearchCandidatesAsync(Guid employerUserId, CandidateSearchRequest filter, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (company is null)
            return Result<PagedResult<CandidateSearchItem>>.Fail("Company profile not found", ErrorType.NotFound);

        if (company.VerificationStatus != VerificationStatus.Verified)
            return Result<PagedResult<CandidateSearchItem>>.Fail(
                "Поиск кандидатов доступен после верификации компании", ErrorType.Forbidden);

        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (items, totalCount) = await _unitOfWork.CandidateProfiles.SearchForEmployerAsync(company.Id, filter, cancellationToken);

        return Result<PagedResult<CandidateSearchItem>>.Ok(new PagedResult<CandidateSearchItem>
        {
            Items = items,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }
}