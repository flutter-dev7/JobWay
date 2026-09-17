using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Auth.Request;

public class VerifyResetCodeRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;

    [Required]
    [StringLength(6, MinimumLength = 6, ErrorMessage = "Code must be 6 digits.")]
    public string Code { get; set; } = string.Empty;
}