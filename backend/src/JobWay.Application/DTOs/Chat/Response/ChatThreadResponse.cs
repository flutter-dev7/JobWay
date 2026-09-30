namespace JobWay.Application.DTOs.Chat.Response;

public class ChatThreadResponse
{
    public Guid JobApplicationId { get; set; }
    public Guid OtherUserId { get; set; }
    public string OtherUserName { get; set; } = null!;
    public string? OtherUserPhotoUrl { get; set; }
    public string VacancyTitle { get; set; } = null!;
    public string LastMessageText { get; set; } = null!;
    public DateTime LastMessageAt { get; set; }
    public int UnreadCount { get; set; }
    public bool OtherUserActive { get; set; }
}