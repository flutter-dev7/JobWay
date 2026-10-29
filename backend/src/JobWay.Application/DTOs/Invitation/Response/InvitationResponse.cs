using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Invitation.Response;

public class InvitationResponse
{
    public Guid Id { get; set; }
    public Guid VacancyId { get; set; }
    public string VacancyTitle { get; set; } = null!;
    public VacancyStatus VacancyStatus { get; set; }
    public Guid CompanyProfileId { get; set; }
    public Guid CompanyUserId { get; set; }
    public string CompanyName { get; set; } = null!;
    public string? CompanyLogoUrl { get; set; }
    public string? Message { get; set; }
    public InvitationStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? RespondedAt { get; set; }
}