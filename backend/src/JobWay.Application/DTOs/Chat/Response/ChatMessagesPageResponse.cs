namespace JobWay.Application.DTOs.Chat.Response;

public class ChatMessagesPageResponse
{
    public List<ChatMessageResponse> Items { get; set; } = [];
    public bool HasMore { get; set; }
}