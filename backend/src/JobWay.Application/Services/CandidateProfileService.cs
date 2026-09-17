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
    private readonly IUnitOfWork _unitOfWork;

    public CandidateProfileService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<CandidateProfileResponse>> GetMyProfileAsync(Guid userId, CancellationToken cancellationToken)
    {
        var profile = await _unitOfWork.CandidateProfiles.GetByUserIdAsync(userId, cancellationToken);

        if (profile is null)
            return Result<CandidateProfileResponse>.Fail("Profile not found", ErrorType.NotFound);

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
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

        return Result<CandidateProfileResponse>.Ok(MapToResponse(profile));
    }

    private static CandidateProfileResponse MapToResponse(CandidateProfile profile) => new()
    {
        Id = profile.Id,
        FullName = profile.FullName,
        BirthDate = profile.BirthDate,
        Location = profile.Location,
        Bio = profile.Bio,
        ResumeFileUrl = profile.ResumeFileUrl,
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