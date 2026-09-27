using JobWay.Application.DTOs.Vacancy.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class VacancyRepository : IVacancyRepository
{
    private readonly AppDbContext _context;

    public VacancyRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<Vacancy?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.Vacancies
            .Include(v => v.CompanyProfile)
            .Include(v => v.RequiredSkills)
            .FirstOrDefaultAsync(v => v.Id == id, cancellationToken);

    public async Task<(List<Vacancy> Items, int TotalCount)> GetActiveAsync(VacancyFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.Vacancies
            .Include(v => v.CompanyProfile)
            .Include(v => v.RequiredSkills)
            .Where(v => v.Status == VacancyStatus.Active);

        if (!string.IsNullOrWhiteSpace(filter.Search))
            query = query.Where(v => EF.Functions.ILike(v.Title, $"%{filter.Search}%"));

        if (filter.EmploymentType is not null)
            query = query.Where(v => v.EmploymentType == filter.EmploymentType);

        if (filter.ExperienceLevel is not null)
            query = query.Where(v => v.ExperienceLevel == filter.ExperienceLevel);

        if (!string.IsNullOrWhiteSpace(filter.Location))
            query = query.Where(v => v.Location != null && EF.Functions.ILike(v.Location, $"%{filter.Location}%"));

        if (filter.SalaryFrom is not null)
            query = query.Where(v => v.SalaryFrom == null || v.SalaryFrom >= filter.SalaryFrom);
        
        if (filter.PaymentType is not null)
            query = query.Where(v => v.PaymentType == filter.PaymentType);

        if (filter.Currency is not null)
            query = query.Where(v => v.Currency == filter.Currency);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(v => v.CreatedAt)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public Task<int> CountCreatedTodayAsync(CancellationToken cancellationToken)
    {
        var todayStart = DateTime.UtcNow.Date;
        var tomorrowStart = todayStart.AddDays(1);

        return _context.Vacancies
            .Where(v => v.Status == VacancyStatus.Active && v.CreatedAt >= todayStart && v.CreatedAt < tomorrowStart)
            .CountAsync(cancellationToken);
    }

    public Task<List<Vacancy>> GetByCompanyProfileIdAsync(Guid companyProfileId, CancellationToken cancellationToken)
        => _context.Vacancies
            .Include(v => v.CompanyProfile)
            .Include(v => v.RequiredSkills)
            .Where(v => v.CompanyProfileId == companyProfileId)
            .OrderByDescending(v => v.CreatedAt)
            .ToListAsync(cancellationToken);

    public void Add(Vacancy vacancy) => _context.Vacancies.Add(vacancy);
    public void Update(Vacancy vacancy) => _context.Vacancies.Update(vacancy);
}