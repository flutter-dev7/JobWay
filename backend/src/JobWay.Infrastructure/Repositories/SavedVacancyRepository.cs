using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class SavedVacancyRepository : ISavedVacancyRepository
{
    private readonly AppDbContext _context;

    public SavedVacancyRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<bool> ExistsAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken)
        => _context.SavedVacancies.AnyAsync(s => s.UserId == userId && s.VacancyId == vacancyId, cancellationToken);

    public Task<SavedVacancy?> GetAsync(Guid userId, Guid vacancyId, CancellationToken cancellationToken)
        => _context.SavedVacancies.FirstOrDefaultAsync(s => s.UserId == userId && s.VacancyId == vacancyId, cancellationToken);

    public Task<List<Vacancy>> GetSavedVacanciesAsync(Guid userId, CancellationToken cancellationToken)
        => _context.SavedVacancies
            .Where(s => s.UserId == userId)
            .Include(s => s.Vacancy).ThenInclude(v => v.CompanyProfile)
            .Include(s => s.Vacancy).ThenInclude(v => v.RequiredSkills)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => s.Vacancy)
            .ToListAsync(cancellationToken);
    
    public async Task<(List<Vacancy> Items, int TotalCount)> GetPagedSavedVacanciesAsync(
        Guid userId, SavedVacanciesFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.SavedVacancies.Where(s => s.UserId == userId);

        var totalCount = await query.CountAsync(cancellationToken);

        var saved = await query
            .OrderByDescending(s => s.CreatedAt)
            .ThenBy(s => s.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Include(s => s.Vacancy).ThenInclude(v => v.CompanyProfile)
            .Include(s => s.Vacancy).ThenInclude(v => v.RequiredSkills)
            .AsSplitQuery()
            .ToListAsync(cancellationToken);

        return (saved.Select(s => s.Vacancy).ToList(), totalCount);
    }

    public Task<List<Guid>> GetSavedVacancyIdsAsync(Guid userId, CancellationToken cancellationToken)
        => _context.SavedVacancies
            .Where(s => s.UserId == userId)
            .Select(s => s.VacancyId)
            .ToListAsync(cancellationToken);

    public void Add(SavedVacancy savedVacancy) => _context.SavedVacancies.Add(savedVacancy);
    public void Remove(SavedVacancy savedVacancy) => _context.SavedVacancies.Remove(savedVacancy);
}