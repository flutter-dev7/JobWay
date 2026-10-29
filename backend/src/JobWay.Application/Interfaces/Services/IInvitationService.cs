using JobWay.Application.Common;
using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Application.DTOs.Invitation.Response;
using JobWay.Application.DTOs.JobApplication.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IInvitationService
{
    Task<Result<InvitationResponse>> InviteAsync(Guid employerUserId, CreateInvitationRequest request, CancellationToken cancellationToken);
    Task<Result<PagedResult<InvitationResponse>>> GetMyAsync(Guid candidateUserId, InvitationFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<JobApplicationResponse>> AcceptAsync(Guid candidateUserId, Guid invitationId, CancellationToken cancellationToken);
    Task<Result<InvitationResponse>> DeclineAsync(Guid candidateUserId, Guid invitationId, CancellationToken cancellationToken);
    Task<Result<List<BlockedVacancyResponse>>> GetBlockedVacanciesAsync(Guid employerUserId, Guid candidateProfileId, CancellationToken cancellationToken);
}