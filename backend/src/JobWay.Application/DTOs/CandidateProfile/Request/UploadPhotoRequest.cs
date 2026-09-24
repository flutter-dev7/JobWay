namespace JobWay.Application.DTOs.CandidateProfile.Request;

public class UploadPhotoRequest
{
    public string FileName { get; set; } = null!;
    public Stream Content { get; set; } = null!;
}