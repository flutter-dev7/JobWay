using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Auth.Response;

public class AuthResponse
{
    public Guid UserId { get; set; }
    public UserRole Role { get; set; }
    public string AccessToken { get; set; } = null!;
    public string RefreshToken { get; set; } = null!;
}