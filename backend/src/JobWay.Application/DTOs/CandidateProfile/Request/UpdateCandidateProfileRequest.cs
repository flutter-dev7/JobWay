using System.ComponentModel.DataAnnotations;
using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.CandidateProfile.Request;

public class UpdateCandidateProfileRequest
{
    [Required]
    public string FullName { get; set; } = string.Empty;

    public DateOnly? BirthDate { get; set; }
    public string? Location { get; set; }
    public string? Bio { get; set; }
    public string? ResumeFileUrl { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public EmploymentType DesiredEmploymentType { get; set; }
    public List<Guid> SkillIds { get; set; } = [];
}