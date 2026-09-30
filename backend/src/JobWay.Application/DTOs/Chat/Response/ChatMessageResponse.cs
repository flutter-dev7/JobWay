namespace JobWay.Application.DTOs.Chat.Response;

public class ChatMessageResponse
{
    public Guid Id { get; set; }
    public Guid JobApplicationId { get; set; }
    public Guid SenderUserId { get; set; }
    public string Text { get; set; } = null!;
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
}