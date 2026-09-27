using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Vacancy.Request;

public class VacancyFilterRequest
{
    public string? Search { get; set; }
    public EmploymentType? EmploymentType { get; set; }
    public ExperienceLevel? ExperienceLevel { get; set; }
    public PaymentType? PaymentType { get; set; }
    public Currency? Currency { get; set; }
    public string? Location { get; set; }
    public decimal? SalaryFrom { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}