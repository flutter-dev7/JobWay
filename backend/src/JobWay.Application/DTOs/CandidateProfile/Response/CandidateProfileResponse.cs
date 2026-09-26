using JobWay.Application.DTOs.Skill.Response;
using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.CandidateProfile.Response;

public class CandidateProfileResponse
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string FullName { get; set; } = null!;
    public DateOnly? BirthDate { get; set; }
    public string? Location { get; set; }
    public string? Bio { get; set; }
    public string? ResumeFileUrl { get; set; }
    public string? PhotoUrl { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public EmploymentType DesiredEmploymentType { get; set; }
    public List<SkillResponse> Skills { get; set; } = [];
}