namespace JobWay.Application.DTOs.Notification.Request;

public class RegisterDeviceTokenRequest
{
    public string Token { get; set; } = null!;
    public string Platform { get; set; } = null!;
}