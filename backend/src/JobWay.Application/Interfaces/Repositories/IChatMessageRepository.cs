using JobWay.Application.DTOs.Chat.Request;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public record ChatThreadSummary(Guid JobApplicationId, DateTime LastMessageAt, int UnreadCount);

public interface IChatMessageRepository
{
    Task<List<ChatMessage>> GetByApplicationIdAsync(Guid jobApplicationId, CancellationToken cancellationToken);
    Task<List<ChatMessage>> GetByApplicationIdSinceAsync(Guid jobApplicationId, DateTime since, CancellationToken cancellationToken);
    Task<(List<ChatMessage> Items, bool HasMore)> GetPageAsync(Guid jobApplicationId, DateTime? before, int pageSize, CancellationToken cancellationToken);
    Task<List<ChatMessage>> GetLatestPerApplicationAsync(List<Guid> jobApplicationIds, CancellationToken cancellationToken);
    Task<List<ChatMessage>> GetLastMessagesAsync(List<Guid> jobApplicationIds, CancellationToken cancellationToken);
    Task<(List<ChatThreadSummary> Items, int TotalCount)> GetThreadSummariesPagedAsync(Guid? candidateProfileId, Guid? companyProfileId, Guid currentUserId, ChatThreadsFilterRequest filter, CancellationToken cancellationToken);
    Task<int> GetUnreadCountAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken);
    Task MarkAllAsReadAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken);
    void Add(ChatMessage message);
}