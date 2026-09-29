using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Auth.Request;

public class DeleteAccountRequest
{
    [Required]
    public string Password { get; set; } = string.Empty;
}