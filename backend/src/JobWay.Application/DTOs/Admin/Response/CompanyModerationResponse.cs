using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Response;

public class CompanyModerationResponse
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string CompanyName { get; set; } = null!;
    public string? Description { get; set; }
    public string? Industry { get; set; }
    public string? Website { get; set; }
    public string? Location { get; set; }
    public string? LogoUrl { get; set; }
    public VerificationStatus VerificationStatus { get; set; }
}