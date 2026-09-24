using JobWay.Domain.Common;
using JobWay.Domain.Enums;

namespace JobWay.Domain.Entities;

public class CandidateProfile : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public string FullName { get; set; } = null!;
    public DateOnly? BirthDate { get; set; }
    public string? Location { get; set; }
    public string? Bio { get; set; }
    public string? ResumeFileUrl { get; set; }
    public string? PhotoUrl { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public EmploymentType DesiredEmploymentType { get; set; }

    public List<Skill> Skills { get; set; } = [];
    public List<JobApplication> Applications { get; set; } = [];
}