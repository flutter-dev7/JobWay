using System.Text.Json;
using JobWay.Application.Common;
using JobWay.Application.DTOs.Analytics.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;

namespace JobWay.Application.Services;

public class AnalyticsService : IAnalyticsService
{
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(5);

    private readonly IUnitOfWork _unitOfWork;
    private readonly IMatchingService _matchingService;
    private readonly ICacheService _cacheService;

    public AnalyticsService(IUnitOfWork unitOfWork, IMatchingService matchingService, ICacheService cacheService)
    {
        _unitOfWork = unitOfWork;
        _matchingService = matchingService;
        _cacheService = cacheService;
    }

    private static string CacheKey(Guid companyProfileId) => $"employer-analytics:{companyProfileId}";

    public async Task<Result<EmployerAnalyticsResponse>> GetEmployerAnalyticsAsync(Guid employerUserId, CancellationToken cancellationToken)
    {
        var companyProfile = await _unitOfWork.CompanyProfiles.GetByUserIdAsync(employerUserId, cancellationToken);
        if (companyProfile is null)
            return Result<EmployerAnalyticsResponse>.Fail("Company profile not found", ErrorType.NotFound);

        var tier = TierRules.GetEffectiveTier(companyProfile);

        // В кэше лежит полный расчёт: тариф накладывается после чтения
        var cached = await _cacheService.GetAsync(CacheKey(companyProfile.Id), cancellationToken);
        var response = cached is null ? null : JsonSerializer.Deserialize<EmployerAnalyticsResponse>(cached);

        if (response is null)
        {
            response = await BuildAnalyticsAsync(companyProfile.Id, cancellationToken);
            await _cacheService.SetAsync(CacheKey(companyProfile.Id), JsonSerializer.Serialize(response), CacheDuration, cancellationToken);
        }

        return Result<EmployerAnalyticsResponse>.Ok(ApplyTier(response, tier));
    }

    // Закрывает на Free то, что обещано только в Pro. Меняет объект уже после записи в кэш
    private static EmployerAnalyticsResponse ApplyTier(EmployerAnalyticsResponse response, CompanyTier tier)
    {
        response.Tier = tier;
        response.IsLimited = tier != CompanyTier.Pro;

        if (!response.IsLimited)
            return response;

        response.AverageMatchScore = 0;
        response.StatusFunnel = [];
        response.TopSkills = [];

        foreach (var vacancy in response.Vacancies)
            vacancy.AverageMatchScore = 0;

        return response;
    }

    private async Task<EmployerAnalyticsResponse> BuildAnalyticsAsync(Guid companyProfileId, CancellationToken cancellationToken)
    {
        var vacancies = await _unitOfWork.Vacancies.GetByCompanyProfileIdAsync(companyProfileId, cancellationToken);
        var applications = await _unitOfWork.JobApplications.GetByCompanyProfileIdAsync(companyProfileId, cancellationToken);

        var applicationsByVacancy = applications
            .GroupBy(a => a.VacancyId)
            .ToDictionary(g => g.Key, g => g.ToList());

        var matchScores = new List<int>();

        var vacancyItems = vacancies.Select(v =>
        {
            var vacancyApplications = applicationsByVacancy.GetValueOrDefault(v.Id, []);
            var scores = vacancyApplications
                .Select(a => _matchingService.Calculate(a.CandidateProfile.Skills, v.RequiredSkills).ScorePercent)
                .ToList();

            matchScores.AddRange(scores);

            return new VacancyAnalyticsItem
            {
                VacancyId = v.Id,
                Title = v.Title,
                Status = v.Status,
                ApplicationsCount = vacancyApplications.Count,
                AverageMatchScore = scores.Count > 0 ? scores.Average() : 0
            };
        }).ToList();

        var statusFunnel = applications
            .GroupBy(a => a.Status)
            .Select(g => new StatusFunnelItem { Status = g.Key, Count = g.Count() })
            .OrderBy(x => x.Status)
            .ToList();

        var topSkills = applications
            .SelectMany(a => a.CandidateProfile.Skills)
            .GroupBy(s => s.Id)
            .Select(g => new TopSkillItem
            {
                SkillId = g.Key,
                NameRu = g.First().NameRu,
                NameTj = g.First().NameTj,
                Count = g.Count()
            })
            .OrderByDescending(x => x.Count)
            .Take(5)
            .ToList();

        return new EmployerAnalyticsResponse
        {
            TotalVacancies = vacancies.Count,
            ActiveVacancies = vacancies.Count(v => v.Status == VacancyStatus.Active),
            TotalApplications = applications.Count,
            AverageMatchScore = matchScores.Count > 0 ? matchScores.Average() : 0,
            StatusFunnel = statusFunnel,
            TopSkills = topSkills,
            Vacancies = vacancyItems
        };
    }
}