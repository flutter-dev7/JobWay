namespace JobWay.Application.DTOs.CompanyProfile.Request;

public class UploadLogoRequest
{
    public string FileName { get; set; } = null!;
    public Stream Content { get; set; } = null!;
}