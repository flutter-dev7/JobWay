using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/invitations")]
public class InvitationController : BaseApiController
{
    private readonly IInvitationService _invitationService;

    public InvitationController(IInvitationService invitationService)
    {
        _invitationService = invitationService;
    }

    [Authorize(Roles = Roles.Employer)]
    [HttpPost]
    public async Task<IActionResult> Invite(CreateInvitationRequest request, CancellationToken cancellationToken)
        => HandleError(await _invitationService.InviteAsync(CurrentUserId, request, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpGet("my")]
    public async Task<IActionResult> GetMy([FromQuery] InvitationFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _invitationService.GetMyAsync(CurrentUserId, filter, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpPost("{id:guid}/accept")]
    public async Task<IActionResult> Accept(Guid id, CancellationToken cancellationToken)
        => HandleError(await _invitationService.AcceptAsync(CurrentUserId, id, cancellationToken));

    [Authorize(Roles = Roles.Candidate)]
    [HttpPost("{id:guid}/decline")]
    public async Task<IActionResult> Decline(Guid id, CancellationToken cancellationToken)
        => HandleError(await _invitationService.DeclineAsync(CurrentUserId, id, cancellationToken));
    
    [Authorize(Roles = Roles.Employer)]
    [HttpGet("candidate/{candidateProfileId:guid}/blocked")]
    public async Task<IActionResult> GetBlocked(Guid candidateProfileId, CancellationToken cancellationToken)
        => HandleError(await _invitationService.GetBlockedVacanciesAsync(CurrentUserId, candidateProfileId, cancellationToken));
}