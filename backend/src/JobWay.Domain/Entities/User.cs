// Domain/Entities/User.cs — заменить целиком
using JobWay.Domain.Common;
using JobWay.Domain.Enums;

namespace JobWay.Domain.Entities;

public class User : BaseEntity
{
    public string Email { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public string PasswordHash { get; set; } = null!;
    public UserRole Role { get; set; }
    public string PreferredLanguage { get; set; } = "ru";
    public bool IsActive { get; set; } = true;

    public CandidateProfile? CandidateProfile { get; set; }
    public CompanyProfile? CompanyProfile { get; set; }
    public List<Notification> Notifications { get; set; } = [];
}