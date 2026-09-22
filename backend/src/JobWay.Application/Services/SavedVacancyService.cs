using JobWay.Application.Common;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.DTOs.Vacancy.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class SavedVacancyService : ISavedVacancyService
{
    private readonly IUnitOfWork _unitOfWork;

    public SavedVacancyService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<Result<string>> SaveAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null)
            return Result<string>.Fail("Vacancy not found", ErrorType.NotFound);

        if (await _unitOfWork.SavedVacancies.ExistsAsync(userId, vacancyId, cancellationToken))
            return Result<string>.Fail("Vacancy already saved", ErrorType.Conflict);

        _unitOfWork.SavedVacancies.Add(new SavedVacancy { UserId = userId, VacancyId = vacancyId });
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("Vacancy saved");
    }

    public async Task<Result<string>> UnsaveAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var saved = await _unitOfWork.SavedVacancies.GetAsync(userId, vacancyId, cancellationToken);
        if (saved is null)
            return Result<string>.Fail("Vacancy is not saved", ErrorType.NotFound);

        _unitOfWork.SavedVacancies.Remove(saved);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result<string>.Ok("Vacancy removed from saved");
    }

    public async Task<Result<List<VacancyResponse>>> GetSavedAsync(Guid userId, CancellationToken cancellationToken)
    {
        var vacancies = await _unitOfWork.SavedVacancies.GetSavedVacanciesAsync(userId, cancellationToken);
        return Result<List<VacancyResponse>>.Ok(vacancies.Select(MapToResponse).ToList());
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