using JobWay.Application.DTOs.Skill.Response;
using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Vacancy.Response;

public class VacancyResponse
{
    public Guid Id { get; set; }
    public Guid CompanyUserId { get; set; }
    public Guid CompanyProfileId { get; set; }
    public string CompanyName { get; set; } = null!;
    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public EmploymentType EmploymentType { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public string? Location { get; set; }
    public decimal? SalaryFrom { get; set; }
    public decimal? SalaryTo { get; set; }
    public VacancyStatus Status { get; set; }
    public List<SkillResponse> Skills { get; set; } = [];
    public DateTime CreatedAt { get; set; }
    public string? CompanyLogoUrl { get; set; }
}