using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/search")]
public class SearchController : BaseApiController
{
    private readonly ISearchService _searchService;

    public SearchController(ISearchService searchService)
    {
        _searchService = searchService;
    }

    [Authorize(Roles = Roles.Candidate)]
    [HttpGet("companies")]
    public async Task<IActionResult> SearchCompanies([FromQuery] CompanySearchRequest filter, CancellationToken cancellationToken)
        => HandleError(await _searchService.SearchCompaniesAsync(filter, cancellationToken));

    [Authorize(Roles = Roles.Employer)]
    [HttpGet("candidates")]
    public async Task<IActionResult> SearchCandidates([FromQuery] CandidateSearchRequest filter, CancellationToken cancellationToken)
        => HandleError(await _searchService.SearchCandidatesAsync(CurrentUserId, filter, cancellationToken));
}