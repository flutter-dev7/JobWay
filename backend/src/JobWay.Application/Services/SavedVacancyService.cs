using JobWay.Application.Common;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.DTOs.Vacancy.Request;
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

    public async Task<Result<PagedResult<VacancyResponse>>> GetSavedAsync(Guid userId, SavedVacanciesFilterRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var (vacancies, totalCount) = await _unitOfWork.SavedVacancies.GetPagedSavedVacanciesAsync(userId, filter, cancellationToken);

        return Result<PagedResult<VacancyResponse>>.Ok(new PagedResult<VacancyResponse>
        {
            Items = vacancies.Select(MapToResponse).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        });
    }

    public async Task<Result<List<Guid>>> GetSavedIdsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var ids = await _unitOfWork.SavedVacancies.GetSavedVacancyIdsAsync(userId, cancellationToken);
        return Result<List<Guid>>.Ok(ids);
    }

    private static VacancyResponse MapToResponse(Vacancy vacancy) => new()
    {
        Id = vacancy.Id,
        CompanyProfileId = vacancy.CompanyProfileId,
        CompanyUserId = vacancy.CompanyProfile.UserId,
        CompanyName = vacancy.CompanyProfile.CompanyName,
        Title = vacancy.Title,
        Description = vacancy.Description,
        EmploymentType = vacancy.EmploymentType,
        ExperienceLevel = vacancy.ExperienceLevel,
        PaymentType = vacancy.PaymentType,
        Currency = vacancy.Currency,
        Location = vacancy.Location,
        CompanyLogoUrl = vacancy.CompanyProfile.LogoUrl,
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
        FeaturedUntil = vacancy.FeaturedUntil,
        CreatedAt = vacancy.CreatedAt
    };
}