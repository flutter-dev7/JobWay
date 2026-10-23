using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Search.Response;

public class CandidateSearchItem
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = null!;
    public string? PhotoUrl { get; set; }
    public string? Location { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public List<string> TopSkills { get; set; } = [];
}