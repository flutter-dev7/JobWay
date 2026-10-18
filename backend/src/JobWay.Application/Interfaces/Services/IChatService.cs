using JobWay.Application.Common;
using JobWay.Application.DTOs.Chat.Request;
using JobWay.Application.DTOs.Chat.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IChatService
{
    Task<Result<PagedResult<ChatThreadResponse>>> GetMyThreadsAsync(Guid currentUserId, ChatThreadsFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<ChatMessagesPageResponse>> GetMessagesAsync(Guid currentUserId, Guid jobApplicationId, ChatMessagesFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<ChatMessageResponse>> SendMessageAsync(Guid currentUserId, Guid jobApplicationId, SendMessageRequest request, CancellationToken cancellationToken);
}