using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Response;

public record AdminUserRow(Guid Id, string Email, UserRole Role, bool IsActive, string? PhotoUrl);