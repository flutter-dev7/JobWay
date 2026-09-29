using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Analytics.Response;

public class EmployerAnalyticsResponse
{
    public int TotalVacancies { get; set; }
    public int ActiveVacancies { get; set; }
    public int TotalApplications { get; set; }
    public double AverageMatchScore { get; set; }
    public List<StatusFunnelItem> StatusFunnel { get; set; } = [];
    public List<TopSkillItem> TopSkills { get; set; } = [];
    public List<VacancyAnalyticsItem> Vacancies { get; set; } = [];
}

public class StatusFunnelItem
{
    public ApplicationStatus Status { get; set; }
    public int Count { get; set; }
}

public class TopSkillItem
{
    public Guid SkillId { get; set; }
    public string NameRu { get; set; } = null!;
    public string NameTj { get; set; } = null!;
    public int Count { get; set; }
}

public class VacancyAnalyticsItem
{
    public Guid VacancyId { get; set; }
    public string Title { get; set; } = null!;
    public VacancyStatus Status { get; set; }
    public int ApplicationsCount { get; set; }
    public double AverageMatchScore { get; set; }
}