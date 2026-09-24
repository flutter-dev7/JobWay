using JobWay.Application.Common;
using JobWay.Application.DTOs.CompanyProfile.Request;
using JobWay.Application.DTOs.CompanyProfile.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ICompanyProfileService
{
    Task<Result<CompanyProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken);
    Task<Result<CompanyProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCompanyProfileRequest request, CancellationToken cancellationToken);
    Task<Result<CompanyProfileResponse>> UploadLogoAsync(Guid userId, UploadLogoRequest request, CancellationToken cancellationToken);
}