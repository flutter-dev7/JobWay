using JobWay.Application.DTOs.Admin.Request;
using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class CompanyProfileRepository : ICompanyProfileRepository
{
    private readonly AppDbContext _context;

    public CompanyProfileRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<CompanyProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.CompanyProfiles.FirstOrDefaultAsync(p => p.Id == id, cancellationToken);

    public Task<CompanyProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.CompanyProfiles.FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

    public Task<List<CompanyProfile>> GetAllAsync(CancellationToken cancellationToken)
        => _context.CompanyProfiles.ToListAsync(cancellationToken);
    
    public async Task<(List<CompanyProfile> Items, int TotalCount)> GetPagedForAdminAsync(
        AdminCompaniesFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = _context.CompanyProfiles.AsQueryable();

        if (filter.Status is not null)
            query = query.Where(c => c.VerificationStatus == filter.Status);

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(c => EF.Functions.ILike(c.CompanyName, $"%{search}%"));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(c => c.CreatedAt)
            .ThenBy(c => c.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
    
    public async Task<(List<CompanySearchItem> Items, int TotalCount)> SearchPublicAsync(
        CompanySearchRequest filter, CancellationToken cancellationToken)
    {
        // Публично видны только верифицированные компании с активным аккаунтом
        var query = _context.CompanyProfiles
            .Where(c => c.VerificationStatus == VerificationStatus.Verified && c.User.IsActive);

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(c =>
                EF.Functions.ILike(c.CompanyName, $"%{search}%")
                || (c.Industry != null && EF.Functions.ILike(c.Industry, $"%{search}%"))
                || (c.Location != null && EF.Functions.ILike(c.Location, $"%{search}%")));
        }

        if (filter.OnlyWithVacancies)
            query = query.Where(c => c.Vacancies.Any(v => v.Status == VacancyStatus.Active));

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Select(c => new CompanySearchItem
            {
                Id = c.Id,
                CompanyName = c.CompanyName,
                Industry = c.Industry,
                Location = c.Location,
                LogoUrl = c.LogoUrl,
                ActiveVacanciesCount = c.Vacancies.Count(v => v.Status == VacancyStatus.Active)
            })
            .OrderByDescending(i => i.ActiveVacanciesCount)
            .ThenBy(i => i.CompanyName)
            .ThenBy(i => i.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public Task<CompanyProfile?> GetPublicByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.CompanyProfiles.FirstOrDefaultAsync(
            c => c.Id == id && c.VerificationStatus == VerificationStatus.Verified && c.User.IsActive,
            cancellationToken);

    public void Update(CompanyProfile profile) => _context.CompanyProfiles.Update(profile);
}