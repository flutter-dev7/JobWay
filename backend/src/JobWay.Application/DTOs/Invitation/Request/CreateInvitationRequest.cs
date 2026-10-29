namespace JobWay.Application.DTOs.Invitation.Request;

public class CreateInvitationRequest
{
    public Guid VacancyId { get; set; }
    public Guid CandidateProfileId { get; set; }
    public string? Message { get; set; }
}