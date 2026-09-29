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

        var cached = await _cacheService.GetAsync(CacheKey(companyProfile.Id), cancellationToken);
        if (cached is not null)
            return Result<EmployerAnalyticsResponse>.Ok(JsonSerializer.Deserialize<EmployerAnalyticsResponse>(cached));

        var vacancies = await _unitOfWork.Vacancies.GetByCompanyProfileIdAsync(companyProfile.Id, cancellationToken);
        var applications = await _unitOfWork.JobApplications.GetByCompanyProfileIdAsync(companyProfile.Id, cancellationToken);

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

        var response = new EmployerAnalyticsResponse
        {
            TotalVacancies = vacancies.Count,
            ActiveVacancies = vacancies.Count(v => v.Status == VacancyStatus.Active),
            TotalApplications = applications.Count,
            AverageMatchScore = matchScores.Count > 0 ? matchScores.Average() : 0,
            StatusFunnel = statusFunnel,
            TopSkills = topSkills,
            Vacancies = vacancyItems
        };

        await _cacheService.SetAsync(CacheKey(companyProfile.Id), JsonSerializer.Serialize(response), CacheDuration, cancellationToken);

        return Result<EmployerAnalyticsResponse>.Ok(response);
    }
}