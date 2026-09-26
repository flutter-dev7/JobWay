namespace JobWay.Application.DTOs.Review.Request;

public class CreateReviewRequest
{
    public Guid JobApplicationId { get; set; }
    public int Rating { get; set; }
    public string? Comment { get; set; }
}