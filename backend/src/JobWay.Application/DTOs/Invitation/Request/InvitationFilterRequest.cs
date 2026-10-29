using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Invitation.Request;

public class InvitationFilterRequest
{
    public InvitationStatus? Status { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}