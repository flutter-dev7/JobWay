namespace JobWay.Application.DTOs.Review.Request;

public class ReviewsFilterRequest
{
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}