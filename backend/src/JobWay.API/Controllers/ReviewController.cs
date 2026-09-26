using JobWay.Application.DTOs.Review.Request;
using JobWay.Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace JobWay.API.Controllers;

[Route("api/review")]
public class ReviewController : BaseApiController
{
    private readonly IReviewService _reviewService;

    public ReviewController(IReviewService reviewService)
    {
        _reviewService = reviewService;
    }

    [HttpPost("create")]
    public async Task<IActionResult> Create(CreateReviewRequest request, CancellationToken cancellationToken)
        => HandleError(await _reviewService.CreateAsync(CurrentUserId, request, cancellationToken));

    [HttpGet("user/{userId:guid}")]
    public async Task<IActionResult> GetForUser(Guid userId, CancellationToken cancellationToken)
        => HandleError(await _reviewService.GetForUserAsync(userId, cancellationToken));

    [HttpGet("user/{userId:guid}/average-rating")]
    public async Task<IActionResult> GetAverageRating(Guid userId, CancellationToken cancellationToken)
        => HandleError(await _reviewService.GetAverageRatingAsync(userId, cancellationToken));
}