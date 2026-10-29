using JobWay.Domain.Common;
using JobWay.Domain.Enums;

namespace JobWay.Domain.Entities;

public class Invitation : BaseEntity
{
    public Guid CompanyProfileId { get; set; }
    public CompanyProfile CompanyProfile { get; set; } = null!;

    public Guid CandidateProfileId { get; set; }
    public CandidateProfile CandidateProfile { get; set; } = null!;

    public Guid VacancyId { get; set; }
    public Vacancy Vacancy { get; set; } = null!;

    public string? Message { get; set; }
    public InvitationStatus Status { get; set; } = InvitationStatus.Pending;
    public DateTime? RespondedAt { get; set; }
}