using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Auth.Request;

public class RegisterRequest
{
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string ConfirmPassword { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public UserRole Role { get; set; }

    public string? FirstName { get; set; }
    public string? LastName { get; set; }

    public string? CompanyName { get; set; }
}