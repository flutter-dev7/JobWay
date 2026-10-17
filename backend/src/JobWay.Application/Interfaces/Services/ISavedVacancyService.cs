using JobWay.Application.Common;
using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.DTOs.Vacancy.Response;

namespace JobWay.Application.Interfaces.Services;

public interface ISavedVacancyService
{
    Task<Result<string>> SaveAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<string>> UnsaveAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<PagedResult<VacancyResponse>>> GetSavedAsync(Guid userId, SavedVacanciesFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<List<Guid>>> GetSavedIdsAsync(Guid userId, CancellationToken cancellationToken);
}