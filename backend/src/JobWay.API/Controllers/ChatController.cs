using JobWay.Application.DTOs.Chat.Request;
using JobWay.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/chat")]
public class ChatController : BaseApiController
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }

    [HttpGet("threads")]
    public async Task<IActionResult> GetMyThreads([FromQuery] ChatThreadsFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _chatService.GetMyThreadsAsync(CurrentUserId, filter, cancellationToken));

    [HttpGet("{jobApplicationId:guid}/messages")]
    public async Task<IActionResult> GetMessages(Guid jobApplicationId, [FromQuery] ChatMessagesFilterRequest filter, CancellationToken cancellationToken)
        => HandleError(await _chatService.GetMessagesAsync(CurrentUserId, jobApplicationId, filter, cancellationToken));

    [HttpPost("{jobApplicationId:guid}/messages")]
    public async Task<IActionResult> SendMessage(Guid jobApplicationId, SendMessageRequest request, CancellationToken cancellationToken)
        => HandleError(await _chatService.SendMessageAsync(CurrentUserId, jobApplicationId, request, cancellationToken));
}