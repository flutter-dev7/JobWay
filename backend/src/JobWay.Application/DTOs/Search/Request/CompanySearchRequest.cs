namespace JobWay.Application.DTOs.Search.Request;

public class CompanySearchRequest
{
    public string? Search { get; set; }
    public bool OnlyWithVacancies { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}