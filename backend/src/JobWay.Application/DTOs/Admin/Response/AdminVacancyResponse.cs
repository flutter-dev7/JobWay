using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Response;

public class AdminVacancyResponse
{
    public Guid Id { get; set; }
    public string Title { get; set; } = null!;
    public VacancyStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? FeaturedUntil { get; set; }
}