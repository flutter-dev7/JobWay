using JobWay.Application.Common;
using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.DTOs.CandidateProfile.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ICandidateProfileService
{
    Task<Result<CandidateProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<CandidateProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCandidateProfileRequest request, CancellationToken cancellationToken);
    Task<Result<CandidateProfileResponse>> UploadResumeAsync(Guid userId, UploadResumeRequest request, CancellationToken cancellationToken);
    Task<Result<CandidateProfileResponse>> UploadPhotoAsync(Guid userId, UploadPhotoRequest request, CancellationToken cancellationToken);
    Task<Result<CandidateProfileResponse>> GetCandidateProfileForEmployerAsync(Guid employerUserId, Guid candidateProfileId, CancellationToken cancellationToken);
}