using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Invitation.Response;

public class BlockedVacancyResponse
{
    public Guid VacancyId { get; set; }
    public InvitationBlockReason Reason { get; set; }
}