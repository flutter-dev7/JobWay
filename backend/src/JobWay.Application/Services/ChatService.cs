using JobWay.Application.Common;
using JobWay.Application.DTOs.Chat.Request;
using JobWay.Application.DTOs.Chat.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class ChatService : IChatService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly INotificationService _notificationService;

    public ChatService(IUnitOfWork unitOfWork, INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _notificationService = notificationService;
    }

    public async Task<Result<PagedResult<ChatThreadResponse>>> GetMyThreadsAsync(Guid currentUserId, ChatThreadsFilterRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        Guid? candidateProfileId = null;
        Guid? companyProfileId = null;

        var candidateProfile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(currentUserId, cancellationToken);
        if (candidateProfile is not null)
        {
            candidateProfileId = candidateProfile.Id;
        }
        else
        {
            var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(currentUserId, cancellationToken);
            companyProfileId = companyProfile?.Id;
        }

        var (summaries, totalCount) = await _unitOfWork.ChatMessages.GetThreadSummariesPagedAsync(
            candidateProfileId, companyProfileId, currentUserId, filter, cancellationToken);

        var result = new PagedResult<ChatThreadResponse>
        {
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        };

        if (summaries.Count == 0)
            return Result<PagedResult<ChatThreadResponse>>.Ok(result);

        var applicationIds = summaries.Select(s => s.JobApplicationId).ToList();

        var applications = (await _unitOfWork.JobApplications.GetByIdsWithParticipantsAsync(applicationIds, cancellationToken))
            .ToDictionary(a => a.Id);

        var lastMessages = (await _unitOfWork.ChatMessages.GetLastMessagesAsync(applicationIds, cancellationToken))
            .GroupBy(m => m.JobApplicationId)
            .ToDictionary(g => g.Key, g => g.OrderByDescending(m => m.CreatedAt).First());

        foreach (var summary in summaries)
        {
            if (!applications.TryGetValue(summary.JobApplicationId, out var application)) continue;
            if (!lastMessages.TryGetValue(summary.JobApplicationId, out var lastMessage)) continue;

            var isCandidate = application.CandidateProfile.UserId == currentUserId;
            var otherUserIsActive = isCandidate
                ? application.Vacancy.CompanyProfile.User.IsActive
                : application.CandidateProfile.User.IsActive;

            result.Items.Add(new ChatThreadResponse
            {
                JobApplicationId = application.Id,
                OtherUserId = isCandidate ? application.Vacancy.CompanyProfile.UserId : application.CandidateProfile.UserId,
                OtherUserName = otherUserIsActive
                    ? (isCandidate ? application.Vacancy.CompanyProfile.CompanyName : application.CandidateProfile.FullName)
                    : "Пользователь удалён",
                OtherUserPhotoUrl = otherUserIsActive
                    ? (isCandidate ? application.Vacancy.CompanyProfile.LogoUrl : application.CandidateProfile.PhotoUrl)
                    : null,
                VacancyTitle = application.Vacancy.Title,
                LastMessageText = lastMessage.Text,
                LastMessageAt = lastMessage.CreatedAt,
                OtherUserActive = otherUserIsActive,
                UnreadCount = summary.UnreadCount
            });
        }

        return Result<PagedResult<ChatThreadResponse>>.Ok(result);
    }

    public async Task<Result<ChatMessagesPageResponse>> GetMessagesAsync(Guid currentUserId, Guid jobApplicationId, ChatMessagesFilterRequest filter, CancellationToken cancellationToken)
    {
        var application = await _unitOfWork.JobApplications.GetByIdAsync(jobApplicationId, cancellationToken);
        if (application is null)
            return Result<ChatMessagesPageResponse>.Fail("Application not found", ErrorType.NotFound);

        if (!IsParticipant(application, currentUserId))
            return Result<ChatMessagesPageResponse>.Fail("You are not a participant of this chat", ErrorType.Forbidden);

        filter.PageSize = Math.Clamp(filter.PageSize, 1, 100);

        List<ChatMessage> messages;
        var hasMore = false;

        if (filter.Since is not null)
            messages = await _unitOfWork.ChatMessages.GetByApplicationIdSinceAsync(jobApplicationId, filter.Since.Value, cancellationToken);
        else
            (messages, hasMore) = await _unitOfWork.ChatMessages.GetPageAsync(jobApplicationId, filter.Before, filter.PageSize, cancellationToken);

        // Подгрузка старой истории не меняет статус прочтения
        if (filter.Before is null)
        {
            await _unitOfWork.ChatMessages.MarkAllAsReadAsync(jobApplicationId, currentUserId, cancellationToken);
            await _unitOfWork.SaveChangesAsync(cancellationToken);
        }

        return Result<ChatMessagesPageResponse>.Ok(new ChatMessagesPageResponse
        {
            Items = messages.Select(Map).ToList(),
            HasMore = hasMore
        });
    }

    public async Task<Result<ChatMessageResponse>> SendMessageAsync(Guid currentUserId, Guid jobApplicationId, SendMessageRequest request, CancellationToken cancellationToken)
    {
        var application = await _unitOfWork.JobApplications.GetByIdAsync(jobApplicationId, cancellationToken);
        if (application is null)
            return Result<ChatMessageResponse>.Fail("Application not found", ErrorType.NotFound);

        if (!IsParticipant(application, currentUserId))
            return Result<ChatMessageResponse>.Fail("You are not a participant of this chat", ErrorType.Forbidden);

        var isCandidate = application.CandidateProfile.UserId == currentUserId;
        var recipientUserId = isCandidate ? application.Vacancy.CompanyProfile.UserId : application.CandidateProfile.UserId;
        var senderName = isCandidate ? application.CandidateProfile.FullName : application.Vacancy.CompanyProfile.CompanyName;

        if (!IsRecipientActive(application, isCandidate))
            return Result<ChatMessageResponse>.Fail("The other participant's account is no longer available", ErrorType.NotFound);

        var message = new ChatMessage
        {
            JobApplicationId = jobApplicationId,
            SenderUserId = currentUserId,
            Text = request.Text.Trim()
        };

        _unitOfWork.ChatMessages.Add(message);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _notificationService.CreateAsync(
            recipientUserId,
            NotificationType.NewMessage,
            "Новое сообщение",
            $"{senderName}: {Truncate(message.Text, 60)}",
            application.Id,
            cancellationToken);

        return Result<ChatMessageResponse>.Ok(Map(message));
    }

    private static bool IsParticipant(JobApplication application, Guid userId)
        => application.CandidateProfile.UserId == userId || application.Vacancy.CompanyProfile.UserId == userId;

    private static bool IsRecipientActive(JobApplication application, bool senderIsCandidate)
        => senderIsCandidate
            ? application.Vacancy.CompanyProfile.User.IsActive
            : application.CandidateProfile.User.IsActive;

    private static string Truncate(string text, int maxLength)
        => text.Length <= maxLength ? text : text[..maxLength] + "…";

    private static ChatMessageResponse Map(ChatMessage message) => new()
    {
        Id = message.Id,
        JobApplicationId = message.JobApplicationId,
        SenderUserId = message.SenderUserId,
        Text = message.Text,
        IsRead = message.IsRead,
        CreatedAt = message.CreatedAt
    };
}