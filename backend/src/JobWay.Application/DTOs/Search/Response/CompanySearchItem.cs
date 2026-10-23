namespace JobWay.Application.DTOs.Search.Response;

public class CompanySearchItem
{
    public Guid Id { get; set; }
    public string CompanyName { get; set; } = null!;
    public string? Industry { get; set; }
    public string? Location { get; set; }
    public string? LogoUrl { get; set; }
    public int ActiveVacanciesCount { get; set; }
}