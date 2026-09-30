using JobWay.Domain.Common;

namespace JobWay.Domain.Entities;

public class ChatMessage : BaseEntity
{
    public Guid JobApplicationId { get; set; }
    public JobApplication JobApplication { get; set; } = null!;

    public Guid SenderUserId { get; set; }

    public string Text { get; set; } = null!;

    public bool IsRead { get; set; }
}