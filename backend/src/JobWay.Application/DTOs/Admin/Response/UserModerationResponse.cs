using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Response;

public class UserModerationResponse
{
    public Guid Id { get; set; }
    public string Email { get; set; } = null!;
    public UserRole Role { get; set; }
    public bool IsActive { get; set; }
}