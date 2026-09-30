using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IChatMessageRepository
{
    Task<List<ChatMessage>> GetByApplicationIdAsync(Guid jobApplicationId, CancellationToken cancellationToken);
    Task<List<ChatMessage>> GetByApplicationIdSinceAsync(Guid jobApplicationId, DateTime since, CancellationToken cancellationToken);
    Task<List<ChatMessage>> GetLatestPerApplicationAsync(List<Guid> jobApplicationIds, CancellationToken cancellationToken);
    Task<int> GetUnreadCountAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken);
    Task MarkAllAsReadAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken);
    void Add(ChatMessage message);
}