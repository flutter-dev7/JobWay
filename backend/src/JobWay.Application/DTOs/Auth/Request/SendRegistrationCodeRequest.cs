using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Auth.Request;

public class SendRegistrationCodeRequest
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = string.Empty;
}