namespace JobWay.Application.DTOs.CandidateProfile.Request;

public class UploadResumeRequest
{
    public string FileName { get; set; } = null!;
    public Stream Content { get; set; } = null!;
}