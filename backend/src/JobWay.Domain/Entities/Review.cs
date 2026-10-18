using JobWay.Domain.Common;
using JobWay.Domain.Enums;

namespace JobWay.Domain.Entities;

public class Review : BaseEntity
{
    // Null, если отклик удалён вместе с аккаунтом одного из участников
    public Guid? JobApplicationId { get; set; }
    public JobApplication? JobApplication { get; set; }
    public string ReviewerName { get; set; } = null!;
    public string? ReviewerPhotoUrl { get; set; }
    public ReviewType Type { get; set; }
    public Guid ReviewerUserId { get; set; }
    public Guid RevieweeUserId { get; set; }

    public int Rating { get; set; } // 1..5
    public string? Comment { get; set; }
}