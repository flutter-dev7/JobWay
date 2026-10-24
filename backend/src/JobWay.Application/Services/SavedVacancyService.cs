using System.Text.Json;
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
    private static readonly TimeSpan IdsCacheDuration = TimeSpan.FromMinutes(10);
    private static readonly TimeSpan ListCacheDuration = TimeSpan.FromMinutes(2);
    private static readonly TimeSpan VersionCacheDuration = TimeSpan.FromDays(1);

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;

    public SavedVacancyService(IUnitOfWork unitOfWork, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
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

        await InvalidateAsync(userId, cancellationToken);

        return Result<string>.Ok("Vacancy saved");
    }

    public async Task<Result<string>> UnsaveAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var saved = await _unitOfWork.SavedVacancies.GetAsync(userId, vacancyId, cancellationToken);
        if (saved is null)
            return Result<string>.Fail("Vacancy is not saved", ErrorType.NotFound);

        _unitOfWork.SavedVacancies.Remove(saved);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await InvalidateAsync(userId, cancellationToken);

        return Result<string>.Ok("Vacancy removed from saved");
    }

    public async Task<Result<PagedResult<VacancyResponse>>> GetSavedAsync(Guid userId, SavedVacanciesFilterRequest filter, CancellationToken cancellationToken)
    {
        filter.PageNumber = Math.Max(filter.PageNumber, 1);
        filter.PageSize = Math.Clamp(filter.PageSize, 1, 50);

        var version = await _cacheService.GetAsync(CacheKeys.SavedVersion(userId), cancellationToken) ?? "0";
        var cacheKey = CacheKeys.Saved(userId, version, filter.PageNumber, filter.PageSize);

        var cached = await _cacheService.GetAsync(cacheKey, cancellationToken);
        if (cached is not null)
        {
            var cachedResult = JsonSerializer.Deserialize<PagedResult<VacancyResponse>>(cached);
            if (cachedResult is not null)
                return Result<PagedResult<VacancyResponse>>.Ok(cachedResult);
        }

        var (vacancies, totalCount) = await _unitOfWork.SavedVacancies.GetPagedSavedVacanciesAsync(userId, filter, cancellationToken);

        var result = new PagedResult<VacancyResponse>
        {
            Items = vacancies.Select(MapToResponse).ToList(),
            PageNumber = filter.PageNumber,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        };

        await _cacheService.SetAsync(cacheKey, JsonSerializer.Serialize(result), ListCacheDuration, cancellationToken);

        return Result<PagedResult<VacancyResponse>>.Ok(result);
    }

    public async Task<Result<List<Guid>>> GetSavedIdsAsync(Guid userId, CancellationToken cancellationToken)
    {
        var cacheKey = CacheKeys.SavedIds(userId);

        var cached = await _cacheService.GetAsync(cacheKey, cancellationToken);
        if (cached is not null)
        {
            var cachedIds = JsonSerializer.Deserialize<List<Guid>>(cached);
            if (cachedIds is not null)
                return Result<List<Guid>>.Ok(cachedIds);
        }

        var ids = await _unitOfWork.SavedVacancies.GetSavedVacancyIdsAsync(userId, cancellationToken);
        await _cacheService.SetAsync(cacheKey, JsonSerializer.Serialize(ids), IdsCacheDuration, cancellationToken);

        return Result<List<Guid>>.Ok(ids);
    }

    // Сбрасываем Id и «версию» страниц списка: прежние страницы больше не читаются
    private async Task InvalidateAsync(Guid userId, CancellationToken cancellationToken)
    {
        await _cacheService.RemoveAsync(CacheKeys.SavedIds(userId), cancellationToken);
        await _cacheService.SetAsync(
            CacheKeys.SavedVersion(userId),
            Guid.NewGuid().ToString("N"),
            VersionCacheDuration,
            cancellationToken);
    }

    private static VacancyResponse MapToResponse(Vacancy vacancy) => new()
    {
        Id = vacancy.Id,
        CompanyProfileId = vacancy.CompanyProfileId,
        CompanyUserId = vacancy.CompanyProfile.UserId,
        CompanyName = vacancy.CompanyProfile.CompanyName,
        Title = vacancy.Title,
        Description = vacancy.Description,
        Responsibilities = vacancy.Responsibilities,
        Requirements = vacancy.Requirements,
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
