using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Auth.Request;

public class VerifyRegistrationCodeRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [StringLength(6, MinimumLength = 6)]
    public string Code { get; set; } = string.Empty;
}