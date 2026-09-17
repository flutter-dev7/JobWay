using JobWay.Application.Common;
using JobWay.Application.DTOs.CompanyProfile.Request;
using JobWay.Application.DTOs.CompanyProfile.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class CompanyProfileService : ICompanyProfileService
{
    private readonly IUnitOfWork _unitOfWork;

    public CompanyProfileService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<CompanyProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CompanyProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        return Result<CompanyProfileResponse>.Ok(MapToResponse(profile));
    }

    public async Task<Result<CompanyProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCompanyProfileRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CompanyProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        profile.CompanyName = request.CompanyName;
        profile.Description = request.Description;
        profile.Industry = request.Industry;
        profile.LogoUrl = request.LogoUrl;
        profile.Website = request.Website;
        profile.Location = request.Location;

        _unitOfWork.CompanyProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<CompanyProfileResponse>.Ok(MapToResponse(profile));
    }

    private static CompanyProfileResponse MapToResponse(CompanyProfile profile) => new()
    {
        Id = profile.Id,
        CompanyName = profile.CompanyName,
        Description = profile.Description,
        Industry = profile.Industry,
        LogoUrl = profile.LogoUrl,
        Website = profile.Website,
        Location = profile.Location,
        VerificationStatus = profile.VerificationStatus
    };
}