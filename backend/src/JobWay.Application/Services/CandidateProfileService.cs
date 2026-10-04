// Application/Services/CandidateProfileService.cs — заменить целиком
using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Application.DTOs.CandidateProfile.Request;
using JobWay.Application.DTOs.CandidateProfile.Response;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class CandidateProfileService : ICandidateProfileService
{
    private static readonly string[] AllowedResumeExtensions = [".pdf", ".doc", ".docx"];
    private static readonly string[] AllowedImageExtensions = [".jpg", ".jpeg", ".png", ".webp", ".heic", ".gif"];
    
    private readonly IUnitOfWork _unitOfWork;
    private readonly IFileStorageService _fileStorageService;
    private readonly ICacheService _cacheService;

    public CandidateProfileService(IUnitOfWork unitOfWork, IFileStorageService fileStorageService, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _fileStorageService = fileStorageService;
        _cacheService = cacheService;
    }

    private static string CacheKey(Guid userId) => $"candidate-profile:{userId}";

    public async Task<Result<CandidateProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cached = await _cacheService.GetAsync(CacheKey(userId), cancellationToken);
        if (cached is not null)
            return Result<CandidateProfileResponse>.Ok(JsonSerializer.Deserialize<CandidateProfileResponse>(cached));

        var profile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CandidateProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        var response = MapToResponse(profile);
        await _cacheService.SetAsync(CacheKey(userId), JsonSerializer.Serialize(response), TimeSpan.FromMinutes(10), cancellationToken);

        return Result<CandidateProfileResponse>.Ok(response);
    }

    public async Task<Result<CandidateProfileResponse>> UpdateMyProfileAsync(Guid userId, UpdateCandidateProfileRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CandidateProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        profile.FullName = request.FullName;
        profile.BirthDate = request.BirthDate;
        profile.Location = request.Location;
        profile.Bio = request.Bio;
        profile.ResumeFileUrl = request.ResumeFileUrl;
        profile.ExperienceLevel = request.ExperienceLevel;
        profile.DesiredEmploymentType = request.DesiredEmploymentType;

        var skills = await _unitOfWork.Skills.GetAllAsync(cancellationToken);
        profile.Skills = skills.Where(s => request.SkillIds.Contains(s.Id)).ToList();

        _unitOfWork.CandidateProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(CacheKey(userId), cancellationToken);

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
    }

    public async Task<Result<CandidateProfileResponse>> UploadResumeAsync(Guid userId, UploadResumeRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CandidateProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        var extension = Path.GetExtension(request.FileName).ToLowerInvariant();
        if (!AllowedResumeExtensions.Contains(extension))
            return Result<CandidateProfileResponse>.Fail("Only PDF and Word documents are allowed", ErrorType.Validation);

        if (!string.IsNullOrEmpty(profile.ResumeFileUrl))
            await _fileStorageService.DeleteAsync("resumes", profile.ResumeFileUrl, cancellationToken);

        var storedFileName = $"{userId}_{Guid.NewGuid()}{extension}";
        var url = await _fileStorageService.SaveAsync("resumes", storedFileName, request.Content, cancellationToken);

        profile.ResumeFileUrl = url;
        _unitOfWork.CandidateProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(CacheKey(userId), cancellationToken);

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
    }

    public async Task<Result<CandidateProfileResponse>> UploadPhotoAsync(Guid userId, UploadPhotoRequest request, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(userId, cancellationToken);
        if (profile is null)
            return Result<CandidateProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        var extension = Path.GetExtension(request.FileName).ToLowerInvariant();
        if (!AllowedImageExtensions.Contains(extension))
            return Result<CandidateProfileResponse>.Fail("Only JPG and PNG images are allowed", ErrorType.Validation);

        if (!string.IsNullOrEmpty(profile.PhotoUrl))
            await _fileStorageService.DeleteAsync("photos", profile.PhotoUrl, cancellationToken);

        var storedFileName = $"{userId}_{Guid.NewGuid()}{extension}";
        var url = await _fileStorageService.SaveAsync("photos", storedFileName, request.Content, cancellationToken);

        profile.PhotoUrl = url;
        _unitOfWork.CandidateProfiles.Update(profile);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(CacheKey(userId), cancellationToken);

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
    }
    
    public async Task<Result<CandidateProfileResponse>> GetCandidateProfileForEmployerAsync(Guid employerUserId, Guid candidateProfileId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<CandidateProfileResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var hasApplied = await _unitOfWork.JobApplications.ExistsForCandidateAndCompanyAsync(candidateProfileId, companyProfile.Id, cancellationToken);
        if (!hasApplied)
            return Result<CandidateProfileResponse>.Fail("You can only view profiles of candidates who applied to your vacancies", ErrorType.Forbidden);

        var profile = await _unitOfWork.CandidateProfiles.GetByIdAsync(candidateProfileId, cancellationToken);
        if (profile is null || !profile.User.IsActive)
            return Result<CandidateProfileResponse>.Fail("Candidate not found", ErrorType.NotFound);

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
    }

    private static CandidateProfileResponse MapToResponse(CandidateProfile profile) => new()
    {
        Id = profile.Id,
        UserId =  profile.UserId,
        FullName = profile.FullName,
        BirthDate = profile.BirthDate,
        Location = profile.Location,
        Bio = profile.Bio,
        ResumeFileUrl = profile.ResumeFileUrl,
        PhotoUrl = profile.PhotoUrl,
        ExperienceLevel = profile.ExperienceLevel,
        DesiredEmploymentType = profile.DesiredEmploymentType,
        Skills = profile.Skills.Select(s => new SkillResponse
        {
            Id = s.Id,
            NameRu = s.NameRu,
            NameTj = s.NameTj,
            Category = s.Category
        }).ToList()
    };
}