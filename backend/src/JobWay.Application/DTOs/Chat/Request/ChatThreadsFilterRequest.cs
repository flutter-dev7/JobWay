namespace JobWay.Application.DTOs.Chat.Request;

public class ChatThreadsFilterRequest
{
    public bool UnreadOnly { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}