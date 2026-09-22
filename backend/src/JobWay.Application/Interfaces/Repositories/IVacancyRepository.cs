using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IVacancyRepository
{
    Task<Vacancy?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<(List<Vacancy> Items, int TotalCount)> GetActiveAsync(VacancyFilterRequest filter, CancellationToken cancellationToken);
    Task<List<Vacancy>> GetByCompanyProfileIdAsync(Guid companyProfileId, CancellationToken cancellationToken);
    Task<int> CountCreatedTodayAsync(CancellationToken cancellationToken);
    void Add(Vacancy vacancy);
    void Update(Vacancy vacancy);
}