using JobWay.Application.Common;
using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.DTOs.CandidateProfile.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ICandidateProfileService
{
    Task<Result<CandidateProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<CandidateProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCandidateProfileRequest request, CancellationToken cancellationToken);
}