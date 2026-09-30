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

        public async Task<Result<List<ChatThreadResponse>>> GetMyThreadsAsync(Guid currentUserId, CancellationToken cancellationToken)
    {
        var applications = await GetMyApplicationsAsync(currentUserId, cancellationToken);
        if (applications.Count == 0)
            return Result<List<ChatThreadResponse>>.Ok([]);

        var latestMessages = await _unitOfWork.ChatMessages.GetLatestPerApplicationAsync(
            applications.Select(a => a.Id).ToList(),
            cancellationToken);

        var threads = new List<ChatThreadResponse>();

        foreach (var application in applications)
        {
            var lastMessage = latestMessages.FirstOrDefault(m => m.JobApplicationId == application.Id);
            if (lastMessage is null) continue;

            var isCandidate = application.CandidateProfile.UserId == currentUserId;
            var otherUserIsActive = isCandidate
                ? application.Vacancy.CompanyProfile.User.IsActive
                : application.CandidateProfile.User.IsActive;

            var unreadCount = await _unitOfWork.ChatMessages.GetUnreadCountAsync(application.Id, currentUserId, cancellationToken);

            threads.Add(new ChatThreadResponse
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
                UnreadCount = unreadCount
            });
        }

        return Result<List<ChatThreadResponse>>.Ok(threads.OrderByDescending(t => t.LastMessageAt).ToList());
    }

    public async Task<Result<List<ChatMessageResponse>>> GetMessagesAsync(Guid currentUserId, Guid jobApplicationId, DateTime? since, CancellationToken cancellationToken)
    {
        var application = await _unitOfWork.JobApplications.GetByIdAsync(jobApplicationId, cancellationToken);
        if (application is null)
            return Result<List<ChatMessageResponse>>.Fail("Application not found", ErrorType.NotFound);

        if (!IsParticipant(application, currentUserId))
            return Result<List<ChatMessageResponse>>.Fail("You are not a participant of this chat", ErrorType.Forbidden);

        var messages = since is null
            ? await _unitOfWork.ChatMessages.GetByApplicationIdAsync(jobApplicationId, cancellationToken)
            : await _unitOfWork.ChatMessages.GetByApplicationIdSinceAsync(jobApplicationId, since.Value, cancellationToken);

        await _unitOfWork.ChatMessages.MarkAllAsReadAsync(jobApplicationId, currentUserId, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<List<ChatMessageResponse>>.Ok(messages.Select(Map).ToList());
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

    private async Task<List<JobApplication>> GetMyApplicationsAsync(Guid currentUserId, CancellationToken cancellationToken)
    {
        var candidateProfile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(currentUserId, cancellationToken);
        if (candidateProfile is not null)
            return await _unitOfWork.JobApplications.GetByCandidateProfileIdAsync(candidateProfile.Id, cancellationToken);

        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(currentUserId, cancellationToken);
        if (companyProfile is not null)
            return await _unitOfWork.JobApplications.GetByCompanyProfileIdAsync(companyProfile.Id, cancellationToken);

        return [];
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