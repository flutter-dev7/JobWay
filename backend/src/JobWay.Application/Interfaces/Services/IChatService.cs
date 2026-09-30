using JobWay.Application.Common;
using JobWay.Application.DTOs.Chat.Request;
using JobWay.Application.DTOs.Chat.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IChatService
{
    Task<Result<List<ChatThreadResponse>>> GetMyThreadsAsync(Guid currentUserId, CancellationToken cancellationToken);
    Task<Result<List<ChatMessageResponse>>> GetMessagesAsync(Guid currentUserId, Guid jobApplicationId, DateTime? since, CancellationToken cancellationToken);
    Task<Result<ChatMessageResponse>> SendMessageAsync(Guid currentUserId, Guid jobApplicationId, SendMessageRequest request, CancellationToken cancellationToken);
}