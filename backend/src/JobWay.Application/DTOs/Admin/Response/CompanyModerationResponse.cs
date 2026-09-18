using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Response;

public class CompanyModerationResponse
{
    public Guid Id { get; set; }
    public string CompanyName { get; set; } = null!;
    public string? Industry { get; set; }
    public string? Location { get; set; }
    public VerificationStatus VerificationStatus { get; set; }
}