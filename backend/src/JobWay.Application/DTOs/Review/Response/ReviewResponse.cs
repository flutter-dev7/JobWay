using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Review.Response;

public class ReviewResponse
{
    public Guid Id { get; set; }
    public ReviewType Type { get; set; }
    public string ReviewerName { get; set; } = null!;
    public string? ReviewerPhotoUrl { get; set; }
    public Guid ReviewerUserId { get; set; }
    public Guid RevieweeUserId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; }
}