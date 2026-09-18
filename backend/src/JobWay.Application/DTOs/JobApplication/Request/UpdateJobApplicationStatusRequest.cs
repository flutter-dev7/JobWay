using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.JobApplication.Request;

public class UpdateJobApplicationStatusRequest
{
    public ApplicationStatus Status { get; set; }
}