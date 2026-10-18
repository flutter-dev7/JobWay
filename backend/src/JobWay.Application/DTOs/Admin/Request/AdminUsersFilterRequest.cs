using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Admin.Request;

public class AdminUsersFilterRequest
{
    public UserRole? Role { get; set; }
    public bool? IsActive { get; set; }
    public string? Search { get; set; }
    public int PageNumber { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}