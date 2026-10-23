namespace JobWay.Application.DTOs.Search.Request;

public class CandidateSearchRequest
{
    public string? Search { get; set; }

    public string? Category { get; set; }

    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}