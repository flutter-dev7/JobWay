using JobWay.Application.Common;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.DTOs.Vacancy.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class VacancyService : IVacancyService
{
    private readonly IUnitOfWork _unitOfWork;

    public VacancyService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<VacancyResponse>> CreateAsync(Guid employerUserId, CreateVacancyRequest request, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);

        if (companyProfile is null)
            return Result<VacancyResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var skills = await _unitOfWork.Skills.GetAllAsync(cancellationToken);

        var vacancy = new Vacancy
        {
            CompanyProfileId = companyProfile.Id,
            CompanyProfile = companyProfile,
            Title = request.Title,
            Description = request.Description,
            EmploymentType = request.EmploymentType,
            ExperienceLevel = request.ExperienceLevel,
            Location = request.Location,
            SalaryFrom = request.SalaryFrom,
            SalaryTo = request.SalaryTo,
            RequiredSkills = skills.Where(s => request.SkillIds.Contains(s.Id)).ToList()
        };

        _unitOfWork.Vacancies.Add(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
    }

    public async Task<Result<VacancyResponse>> UpdateAsync(Guid employerUserId, Guid vacancyId, UpdateVacancyRequest request, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<VacancyResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<VacancyResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        if (vacancy.CompanyProfileId != companyProfile.Id)
            return Result<VacancyResponse>.Fail("You do not own this vacancy", ErrorType.Forbidden);

        vacancy.Title = request.Title;
        vacancy.Description = request.Description;
        vacancy.EmploymentType = request.EmploymentType;
        vacancy.ExperienceLevel = request.ExperienceLevel;
        vacancy.Location = request.Location;
        vacancy.SalaryFrom = request.SalaryFrom;
        vacancy.SalaryTo = request.SalaryTo;

        var skills = await _unitOfWork.Skills.GetAllAsync(cancellationToken);
        vacancy.RequiredSkills = skills.Where(s => request.SkillIds.Contains(s.Id)).ToList();

        _unitOfWork.Vacancies.Update(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
    }

    public async Task<Result<VacancyResponse>> PublishAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<VacancyResponse>.Fail("Company profile not found", ErrorType.NotFound);

        if (companyProfile.VerificationStatus != VerificationStatus.Verified)
            return Result<VacancyResponse>.Fail("Company must be verified by an admin before publishing vacancies", ErrorType.Forbidden);

        return await ChangeStatusAsync(employerUserId, vacancyId, VacancyStatus.Active, cancellationToken);
    }

    public async Task<Result<VacancyResponse>> CloseAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken)
        => await ChangeStatusAsync(employerUserId, vacancyId, VacancyStatus.Closed, cancellationToken);

    public async Task<Result<VacancyResponse>> GetByIdAsync(Guid vacancyId, CancellationToken cancellationToken)
    {
        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);

        if (vacancy is null)
            return Result<VacancyResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
    }

    public async Task<Result<PagedResult<VacancyResponse>>> GetActiveAsync(VacancyFilterRequest filter, CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _unitOfWork.Vacancies.GetActiveAsync(filter, cancellationToken);

        var result = new PagedResult<VacancyResponse>
        {
            Items = items.Select(MapToResponse).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        };

        return Result<PagedResult<VacancyResponse>>.Ok(result);
    }

    public async Task<Result<List<VacancyResponse>>> GetMyVacanciesAsync(Guid employerUserId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);

        if (companyProfile is null)
            return Result<List<VacancyResponse>>.Fail("Company profile not found", ErrorType.NotFound);

        var vacancies = await _unitOfWork.Vacancies.GetByCompanyProfileIdAsync(companyProfile.Id, cancellationToken);
        return Result<List<VacancyResponse>>.Ok(vacancies.Select(MapToResponse).ToList());
    }

    private async Task<Result<VacancyResponse>> ChangeStatusAsync(Guid employerUserId, Guid vacancyId, VacancyStatus status, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<VacancyResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<VacancyResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        if (vacancy.CompanyProfileId != companyProfile.Id)
            return Result<VacancyResponse>.Fail("You do not own this vacancy", ErrorType.Forbidden);

        vacancy.Status = status;

        _unitOfWork.Vacancies.Update(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
    }

    private static VacancyResponse MapToResponse(Vacancy vacancy) => new()
    {
        Id = vacancy.Id,
        CompanyProfileId = vacancy.CompanyProfileId,
        CompanyName = vacancy.CompanyProfile.CompanyName,
        Title = vacancy.Title,
        Description = vacancy.Description,
        EmploymentType = vacancy.EmploymentType,
        ExperienceLevel = vacancy.ExperienceLevel,
        Location = vacancy.Location,
        SalaryFrom = vacancy.SalaryFrom,
        SalaryTo = vacancy.SalaryTo,
        Status = vacancy.Status,
        Skills = vacancy.RequiredSkills.Select(s => new SkillResponse
        {
            Id = s.Id,
            NameRu = s.NameRu,
            NameTj = s.NameTj,
            Category = s.Category
        }).ToList(),
        CreatedAt = vacancy.CreatedAt
    };
}