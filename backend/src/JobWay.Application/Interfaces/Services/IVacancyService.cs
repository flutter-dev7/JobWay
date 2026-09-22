using JobWay.Application.Common;
using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.DTOs.Vacancy.Response;

namespace JobWay.Application.Interfaces.Services;

public interface IVacancyService
{
    Task<Result<VacancyResponse>> CreateAsync(Guid employerUserId, CreateVacancyRequest request, CancellationToken cancellationToken);
    Task<Result<VacancyResponse>> UpdateAsync(Guid employerUserId, Guid vacancyId, UpdateVacancyRequest request, CancellationToken cancellationToken);
    Task<Result<VacancyResponse>> PublishAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<VacancyResponse>> CloseAsync(Guid employerUserId, Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<VacancyResponse>> GetByIdAsync(Guid vacancyId, CancellationToken cancellationToken);
    Task<Result<PagedResult<VacancyResponse>>> GetActiveAsync(VacancyFilterRequest filter, CancellationToken cancellationToken);
    Task<Result<List<VacancyResponse>>> GetMyVacanciesAsync(Guid employerUserId, CancellationToken cancellationToken);
    Task<Result<int>> GetTodayCountAsync(CancellationToken cancellationToken);
}