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

public class VacancyService : IVacancyService
{
    private const string TodayCountCacheKey = "vacancies:today-count";
    private const int MatchNotificationThreshold = 70;

    private readonly IUnitOfWork _unitOfWork;
    private readonly ICacheService _cacheService;
    private readonly IMatchingService _matchingService;
    private readonly INotificationService _notificationService;

    public VacancyService(
        IUnitOfWork unitOfWork,
        ICacheService cacheService,
        IMatchingService matchingService,
        INotificationService notificationService)
    {
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
        _matchingService = matchingService;
        _notificationService = notificationService;
    }

    private static string VacancyCacheKey(Guid id) => $"vacancy:{id}";

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
            PaymentType = request.PaymentType,
            Currency = request.Currency,
            Location = request.Location,
            SalaryFrom = request.SalaryFrom,
            SalaryTo = request.SalaryTo,
            RequiredSkills = skills.Where(s => request.SkillIds.Contains(s.Id)).ToList()
        };

        _unitOfWork.Vacancies.Add(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(TodayCountCacheKey, cancellationToken);

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
        vacancy.PaymentType = request.PaymentType;
        vacancy.Currency = request.Currency; 
        vacancy.Location = request.Location;
        vacancy.SalaryFrom = request.SalaryFrom;
        vacancy.SalaryTo = request.SalaryTo;

        var skills = await _unitOfWork.Skills.GetAllAsync(cancellationToken);
        vacancy.RequiredSkills = skills.Where(s => request.SkillIds.Contains(s.Id)).ToList();

        _unitOfWork.Vacancies.Update(vacancy);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        await _cacheService.RemoveAsync(VacancyCacheKey(vacancyId), cancellationToken);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
    }

    public async Task<Result<VacancyResponse>> PublishAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<VacancyResponse>.Fail("Company profile not found", ErrorType.NotFound);

        if (companyProfile.VerificationStatus != VerificationStatus.Verified)
            return Result<VacancyResponse>.Fail("Company must be verified by an admin before publishing vacancies", ErrorType.Forbidden);

        var result = await ChangeStatusAsync(employerUserId, vacancyId, VacancyStatus.Active, cancellationToken);

        if (result.IsSuccess)
            await NotifyMatchingCandidatesAsync(vacancyId, cancellationToken);

        return result;
    }

    private async Task NotifyMatchingCandidatesAsync(Guid vacancyId, CancellationToken cancellationToken)
    {
        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);
        if (vacancy is null) return;

        var candidates = await _unitOfWork.CandidateProfiles.GetAllWithSkillsAsync(cancellationToken);

        foreach (var candidate in candidates)
        {
            var match = _matchingService.Calculate(candidate.Skills, vacancy.RequiredSkills);
            if (match.ScorePercent < MatchNotificationThreshold) continue;

            await _notificationService.CreateAsync(
                candidate.UserId,
                NotificationType.NewMatchingVacancy,
                "Подходящая вакансия",
                $"«{vacancy.Title}» в {vacancy.CompanyProfile.CompanyName} — совпадение {match.ScorePercent}%",
                vacancy.Id,
                cancellationToken);
        }
    }

    public async Task<Result<int>> GetTodayCountAsync(CancellationToken cancellationToken)
    {
        var cached = await _cacheService.GetAsync(TodayCountCacheKey, cancellationToken);
        if (cached is not null && int.TryParse(cached, out var cachedCount))
            return Result<int>.Ok(cachedCount);

        var count = await _unitOfWork.Vacancies.CountCreatedTodayAsync(cancellationToken);
        await _cacheService.SetAsync(TodayCountCacheKey, count.ToString(), TimeSpan.FromMinutes(5), cancellationToken);

        return Result<int>.Ok(count);
    }

    public async Task<Result<VacancyResponse>> CloseAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken)
        => await ChangeStatusAsync(employerUserId, vacancyId, VacancyStatus.Closed, cancellationToken);

    public async Task<Result<VacancyResponse>> GetByIdAsync(Guid vacancyId, CancellationToken cancellationToken)
    {
        var cached = await _cacheService.GetAsync(VacancyCacheKey(vacancyId), cancellationToken);
        if (cached is not null)
            return Result<VacancyResponse>.Ok(JsonSerializer.Deserialize<VacancyResponse>(cached));

        var vacancy = await _unitOfWork.Vacancies.GetByIdAsync(vacancyId, cancellationToken);

        if (vacancy is null)
            return Result<VacancyResponse>.Fail("Vacancy not found", ErrorType.NotFound);

        var response = MapToResponse(vacancy);
        await _cacheService.SetAsync(VacancyCacheKey(vacancyId), JsonSerializer.Serialize(response), TimeSpan.FromMinutes(5), cancellationToken);

        return Result<VacancyResponse>.Ok(response);
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

        await _cacheService.RemoveAsync(VacancyCacheKey(vacancyId), cancellationToken);

        return Result<VacancyResponse>.Ok(MapToResponse(vacancy));
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
        SalaryFrom = vacancy.SalaryFrom,
        SalaryTo = vacancy.SalaryTo,
        Status = vacancy.Status,
        CompanyLogoUrl = vacancy.CompanyProfile.LogoUrl,
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