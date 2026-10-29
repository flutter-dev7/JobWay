using JobWay.Application.Common;
using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Application.DTOs.Invitation.Response;
using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.DTOs.JobApplication.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class InvitationService : IInvitationService
{
    public const int MaxMessageLength = 500;
    private const string AcceptedCoverMessage = "Отклик по приглашению работодателя";

    private readonly IUnitOfWork _unitOfWork;
    private readonly INotificationService _notificationService;
    private readonly IJobApplicationService _jobApplicationService;
    private readonly ICacheService _cacheService;

    public InvitationService(
        IUnitOfWork unitOfWork,
        INotificationService notificationService,
        IJobApplicationService jobApplicationService,
        ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _notificationService = notificationService;
        _jobApplicationService = jobApplicationService;
        _cacheService = cacheService;
    }

    public async Task<Result<InvitationResponse>> InviteAsync(Guid employerUserId, CreateInvitationRequest request, CancellationToken cancellationToken)
    {
        var message = string.IsNullOrWhiteSpace(request.Message) ? null : request.Message.Trim();
        if (message is not null && message.Length > MaxMessageLength)
            return Result<InvitationResponse>.Fail($"Сообщение слишком длинное (максимум {MaxMessageLength} символов)", ErrorType.Validation);

        var company = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (company is null)
            return Result<InvitationResponse>.Fail("Company profile not found", ErrorType.NotFound);

        if (company.VerificationStatus != VerificationStatus.Verified)
            return Result<InvitationResponse>.Fail("Приглашать кандидатов можно после верификации компании", ErrorType.Forbidden);

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(request.VacancyId, cancellationToken);
        if (vacancy is null)
            return Result<InvitationResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        if (vacancy.CompanyProfileId != company.Id)
            return Result<InvitationResponse>.Fail("You do not own this vacancy", ErrorType.Forbidden);

        if (vacancy.Status != VacancyStatus.Active)
            return Result<InvitationResponse>.Fail("Пригласить можно только на активную вакансию", ErrorType.Validation);

        var candidate = await _unitOfWork.CandidateProfiles.GetByIdAsync(request.CandidateProfileId, cancellationToken);
        if (candidate is null || !candidate.User.IsActive)
            return Result<InvitationResponse>.Fail("Candidate not found", ErrorType.NotFound);

        // Те же правила доступа, что и к профилю: открытый для поиска либо уже откликавшийся на вашу компанию
        if (!candidate.IsVisibleToEmployers
            && !await _unitOfWork.JobApplications.ExistsForCandidateAndCompanyAsync(candidate.Id, company.Id, cancellationToken))
            return Result<InvitationResponse>.Fail("Кандидат не открыл профиль для поиска", ErrorType.Forbidden);

        if (await _unitOfWork.JobApplications.ExistsAsync(candidate.Id, vacancy.Id, cancellationToken))
            return Result<InvitationResponse>.Fail("Кандидат уже откликался на эту вакансию", ErrorType.Conflict);

        if (await _unitOfWork.Invitations.ExistsAsync(candidate.Id, vacancy.Id, cancellationToken))
            return Result<InvitationResponse>.Fail("Вы уже приглашали этого кандидата на эту вакансию", ErrorType.Conflict);

        var limit = TierRules.GetDailyInvitationLimit(company);
        var used = await _unitOfWork.Invitations.CountCreatedSinceAsync(company.Id, TierRules.TodayStartUtc(), cancellationToken);

        if (used >= limit)
            return Result<InvitationResponse>.Fail(
                $"Лимит приглашений на сегодня исчерпан ({limit}). Он обновится завтра.",
                ErrorType.Forbidden);

        var invitation = new Invitation
        {
            CompanyProfileId = company.Id,
            CompanyProfile = company,
            CandidateProfileId = candidate.Id,
            CandidateProfile = candidate,
            VacancyId = vacancy.Id,
            Vacancy = vacancy,
            Message = message
        };

        _unitOfWork.Invitations.Add(invitation);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        await _cacheService.RemoveAsync(CacheKeys.Subscription(employerUserId), cancellationToken);

        await _notificationService.CreateAsync(
            candidate.UserId,
            NotificationType.InvitationReceived,
            "Приглашение на вакансию",
            $"{company.CompanyName} приглашает вас на вакансию «{vacancy.Title}»",
            invitation.Id,
            cancellationToken);

        return Result<InvitationResponse>.Ok(Map(invitation));
    }

    public async Task<Result<PagedResult<InvitationResponse>>> GetMyAsync(Guid candidateUserId, InvitationFilterRequest filter, CancellationToken cancellationToken)
    {
        var candidate = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(candidateUserId, cancellationToken);
        if (candidate is null)
            return Result<PagedResult<InvitationResponse>>.Fail("Candidate profile not found", ErrorType.NotFound);

        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (items, totalCount) = await _unitOfWork.Invitations.GetPagedByCandidateProfileIdAsync(candidate.Id, filter, cancellationToken);

        return Result<PagedResult<InvitationResponse>>.Ok(new PagedResult<InvitationResponse>
        {
            Items = items.Select(Map).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }

    public async Task<Result<JobApplicationResponse>> AcceptAsync(Guid candidateUserId, Guid invitationId, CancellationToken cancellationToken)
    {
        var invitation = await _unitOfWork.Invitations.GetByIdAsync(invitationId, cancellationToken);
        if (invitation is null || invitation.CandidateProfile.UserId != candidateUserId)
            return Result<JobApplicationResponse>.Fail("Invitation not found", ErrorType.NotFound);

        if (invitation.Status != InvitationStatus.Pending)
            return Result<JobApplicationResponse>.Fail("Приглашение уже обработано", ErrorType.Validation);

        // Принятие приглашения это обычный отклик: совпадение навыков, уведомление работодателю и чат работают как всегда
        var apply = await _jobApplicationService.ApplyAsync(
            candidateUserId,
            invitation.VacancyId,
            new CreateJobApplicationRequest { CoverMessage = AcceptedCoverMessage },
            cancellationToken);

        // Конфликт значит, что кандидат уже откликнулся сам: приглашение тоже закрываем.
        // Закрытая вакансия или другая ошибка оставляют приглашение в ожидании
        if (apply.IsSuccess || apply.ErrorType == ErrorType.Conflict)
            await MarkRespondedAsync(invitation, InvitationStatus.Accepted, cancellationToken);

        return apply;
    }

    public async Task<Result<InvitationResponse>> DeclineAsync(Guid candidateUserId, Guid invitationId, CancellationToken cancellationToken)
    {
        var invitation = await _unitOfWork.Invitations.GetByIdAsync(invitationId, cancellationToken);
        if (invitation is null || invitation.CandidateProfile.UserId != candidateUserId)
            return Result<InvitationResponse>.Fail("Invitation not found", ErrorType.NotFound);

        if (invitation.Status != InvitationStatus.Pending)
            return Result<InvitationResponse>.Fail("Приглашение уже обработано", ErrorType.Validation);

        await MarkRespondedAsync(invitation, InvitationStatus.Declined, cancellationToken);

        await _notificationService.CreateAsync(
            invitation.CompanyProfile.UserId,
            NotificationType.InvitationDeclined,
            "Приглашение отклонено",
            $"{invitation.CandidateProfile.FullName} отклонил(а) приглашение на вакансию «{invitation.Vacancy.Title}»",
            invitation.Id,
            cancellationToken);

        return Result<InvitationResponse>.Ok(Map(invitation));
    }
    
    public async Task<Result<List<BlockedVacancyResponse>>> GetBlockedVacanciesAsync(Guid employerUserId, Guid candidateProfileId, CancellationToken cancellationToken)
    {
        var company = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (company is null)
            return Result<List<BlockedVacancyResponse>>.Fail("Company profile not found", ErrorType.NotFound);

        // Только вакансии этой компании: чужие отклики кандидата работодатель не видит
        var appliedIds = await _unitOfWork.JobApplications.GetVacancyIdsByCandidateAndCompanyAsync(candidateProfileId, company.Id, cancellationToken);
        var invitations = await _unitOfWork.Invitations.GetByCandidateAndCompanyAsync(candidateProfileId, company.Id, cancellationToken);

        var blocked = appliedIds
            .Distinct()
            .Select(id => new BlockedVacancyResponse { VacancyId = id, Reason = InvitationBlockReason.Applied })
            .ToList();

        foreach (var invitation in invitations)
        {
            if (blocked.Any(b => b.VacancyId == invitation.VacancyId)) continue;

            blocked.Add(new BlockedVacancyResponse
            {
                VacancyId = invitation.VacancyId,
                Reason = invitation.Status switch
                {
                    InvitationStatus.Declined => InvitationBlockReason.Declined,
                    InvitationStatus.Accepted => InvitationBlockReason.Applied,
                    _ => InvitationBlockReason.Invited
                }
            });
        }

        return Result<List<BlockedVacancyResponse>>.Ok(blocked);
    }

    private async Task MarkRespondedAsync(Invitation invitation, InvitationStatus status, CancellationToken cancellationToken)
    {
        invitation.Status = status;
        invitation.RespondedAt = DateTime.UtcNow;

        _unitOfWork.Invitations.Update(invitation);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
    }

    private static InvitationResponse Map(Invitation invitation) => new()
    {
        Id = invitation.Id,
        VacancyId = invitation.VacancyId,
        VacancyTitle = invitation.Vacancy.Title,
        VacancyStatus = invitation.Vacancy.Status,
        CompanyProfileId = invitation.CompanyProfileId,
        CompanyUserId = invitation.CompanyProfile.UserId,
        CompanyName = invitation.CompanyProfile.CompanyName,
        CompanyLogoUrl = invitation.CompanyProfile.LogoUrl,
        Message = invitation.Message,
        Status = invitation.Status,
        CreatedAt = invitation.CreatedAt,
        RespondedAt = invitation.RespondedAt
    };
}