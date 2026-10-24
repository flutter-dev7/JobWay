using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SearchService : ISearchService
{
    private const int MaxCachedPages = 3;
    private const int MaxCachedQueryLength = 40;
    private static readonly TimeSpan CompaniesCacheDuration = TimeSpan.FromMinutes(2);

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;

    public SearchService(IUnitOfWork unitOfWork, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
    }

    public async Task<Result<PagedResult<CompanySearchItem>>> SearchCompaniesAsync(CompanySearchRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var normalizedSearch = filter.Search?.Trim().ToLowerInvariant() ?? string.Empty;
        var cacheable = filter.PageNumber <= MaxCachedPages && normalizedSearch.Length <= MaxCachedQueryLength;
        var cacheKey = CacheKeys.CompanySearch(normalizedSearch, filter.OnlyWithVacancies, filter.PageNumber, filter.PageSize);

        if (cacheable)
        {
            var cached = await _cacheService.GetAsync(cacheKey, cancellationToken);
            if (cached is not null)
            {
                var cachedResult = JsonSerializer.Deserialize<PagedResult<CompanySearchItem>>(cached);
                if (cachedResult is not null)
                    return Result<PagedResult<CompanySearchItem>>.Ok(cachedResult);
            }
        }

        var (items, totalCount) = await _unitOfWork.CompanyProfiles.SearchPublicAsync(filter, cancellationToken);

        var result = new PagedResult<CompanySearchItem>
        {
            Items = items,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        };

        if (cacheable)
            await _cacheService.SetAsync(cacheKey, JsonSerializer.Serialize(result), CompaniesCacheDuration, cancellationToken);

        return Result<PagedResult<CompanySearchItem>>.Ok(result);
    }

    // Поиск кандидатов не кэшируется: отозванное согласие должно действовать сразу
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

        var (items, totalCount) = await _unitOfWork.CandidateProfiles.SearchForEmployerAsync(filter, cancellationToken);

        return Result<PagedResult<CandidateSearchItem>>.Ok(new PagedResult<CandidateSearchItem>
        {
            Items = items,
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }
}