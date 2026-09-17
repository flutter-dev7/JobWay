using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.CompanyProfile.Request;

public class UpdateCompanyProfileRequest
{
    [Required]
    public string CompanyName { get; set; } = string.Empty;

    public string? Description { get; set; }
    public string? Industry { get; set; }
    public string? LogoUrl { get; set; }
    public string? Website { get; set; }
    public string? Location { get; set; }
}