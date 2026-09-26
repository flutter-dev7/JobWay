// Application/Services/CompanyProfileService.cs — заменить целиком
using System.Text.Json;
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
    private static readonly string[] AllowedImageExtensions = [".jpg", ".jpeg", ".png"];

    private readonly IUnitOfWork _unitOfWork;
    private readonly IFileStorageService _fileStorageService;
    private readonly ICacheService _cacheService;

    public CompanyProfileService(IUnitOfWork unitOfWork, IFileStorageService fileStorageService, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _fileStorageService = fileStorageService;
        _cacheService = cacheService;
    }

    private static string CacheKey(Guid userId) => $"company-profile:{userId}";

    public async Task<Result<CompanyProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cached = await _cacheService.GetAsync(CacheKey(userId), cancellationToken);
        if (cached is not null)
            return Result<CompanyProfileResponse>.Ok(JsonSerializer.Deserialize<CompanyProfileResponse>(cached));

        var profile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CompanyProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        var response = MapToResponse(profile);
        await _cacheService.SetAsync(CacheKey(userId), JsonSerializer.Serialize(response), TimeSpan.FromMinutes(10), cancellationToken);

        return Result<CompanyProfileResponse>.Ok(response);
    }

    public async Task<Result<CompanyProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCompanyProfileRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CompanyProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        profile.CompanyName = request.CompanyName;
        profile.Description = request.Description;
        profile.Industry = request.Industry;
        profile.Website = request.Website;
        profile.Location = request.Location;

        _unitOfWork.CompanyProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(CacheKey(userId), cancellationToken);

        return Result<CompanyProfileResponse>.Ok(MapToResponse(profile));
    }

    public async Task<Result<CompanyProfileResponse>> UploadLogoAsync(Guid userId, UploadLogoRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CompanyProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        var extension = Path.GetExtension(request.FileName).ToLowerInvariant();
        if (!AllowedImageExtensions.Contains(extension))
            return Result<CompanyProfileResponse>.Fail("Only JPG and PNG images are allowed", ErrorType.Validation);

        var storedFileName = $"{userId}_{Guid.NewGuid()}{extension}";
        var url = await _fileStorageService.SaveAsync("photos", storedFileName, request.Content, cancellationToken);

        profile.LogoUrl = url;
        _unitOfWork.CompanyProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(CacheKey(userId), cancellationToken);

        return Result<CompanyProfileResponse>.Ok(MapToResponse(profile));
    }

    private static CompanyProfileResponse MapToResponse(CompanyProfile profile) => new()
    {
        Id = profile.Id,
        UserId = profile.UserId,
        CompanyName = profile.CompanyName,
        Description = profile.Description,
        Industry = profile.Industry,
        LogoUrl = profile.LogoUrl,
        Website = profile.Website,
        Location = profile.Location,
        VerificationStatus = profile.VerificationStatus
    };
}