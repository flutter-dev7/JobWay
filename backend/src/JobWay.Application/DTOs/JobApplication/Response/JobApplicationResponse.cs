using JobWay.Application.DTOs.Skill.Response;
using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.JobApplication.Response;

public class JobApplicationResponse
{
    public Guid Id { get; set; }
    public Guid VacancyId { get; set; }
    public string VacancyTitle { get; set; } = null!;
    public string CompanyName { get; set; } = null!;
    public Guid CandidateProfileId { get; set; }
    public string CandidateFullName { get; set; } = null!;
    public ApplicationStatus Status { get; set; }
    public int MatchScore { get; set; }
    public List<SkillResponse> MatchedSkills { get; set; } = [];
    public List<SkillResponse> MissingSkills { get; set; } = [];
    public string? CoverMessage { get; set; }
    public DateTime CreatedAt { get; set; }
}