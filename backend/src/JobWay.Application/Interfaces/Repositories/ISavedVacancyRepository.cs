using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ISavedVacancyRepository
{
    Task<bool> ExistsAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken);
    Task<SavedVacancy?> GetAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken);
    Task<List<Vacancy>> GetSavedVacanciesAsync(Guid userId, CancellationToken cancellationToken);
    void Add(SavedVacancy savedVacancy);
    void Remove(SavedVacancy savedVacancy);
}