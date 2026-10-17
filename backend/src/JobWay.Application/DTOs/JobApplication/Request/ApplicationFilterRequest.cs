using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.JobApplication.Request;

public class ApplicationFilterRequest
{
    public ApplicationStatus? Status { get; set; }
    public string? SortBy { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 10;
}