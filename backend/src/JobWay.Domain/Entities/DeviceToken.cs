using JobWay.Domain.Common;

namespace JobWay.Domain.Entities;

public class DeviceToken : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public string Token { get; set; } = null!;
    public string Platform { get; set; } = null!; // "android" / "ios"
}