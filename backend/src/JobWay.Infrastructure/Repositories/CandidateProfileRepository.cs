using JobWay.Application.DTOs.Search.Request;
using JobWay.Application.DTOs.Search.Response;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class CandidateProfileRepository : ICandidateProfileRepository
{
    private readonly AppDbContext _context;

    public CandidateProfileRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<CandidateProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.CandidateProfiles.Include(p => p.Skills).FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

    public Task<CandidateProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.CandidateProfiles
            .Include(p => p.Skills)
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.Id == id, cancellationToken);

    public Task<List<CandidateProfile>> GetAllAsync(CancellationToken cancellationToken)
        => _context.CandidateProfiles.ToListAsync(cancellationToken);
    
    public Task<List<CandidateProfile>> GetAllWithSkillsAsync(CancellationToken cancellationToken)
        => _context.CandidateProfiles
            .Include(c => c.Skills)
            .ToListAsync(cancellationToken);
    
    public async Task<(List<CandidateSearchItem> Items, int TotalCount)> SearchForEmployerAsync(
        Guid companyProfileId, CandidateSearchRequest filter, CancellationToken cancellationToken)
    {
        // Кандидат виден, если он включил видимость или уже откликался на вакансии этой компании
        var query = _context.CandidateProfiles.Where(c =>
            c.User.IsActive
            && (c.IsVisibleToEmployers
                || c.Applications.Any(a => a.Vacancy.CompanyProfileId == companyProfileId)));

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            var search = filter.Search.Trim();
            query = query.Where(c =>
                EF.Functions.ILike(c.FullName, $"%{search}%")
                || (c.Location != null && EF.Functions.ILike(c.Location, $"%{search}%"))
                || c.Skills.Any(s => EF.Functions.ILike(s.NameRu, $"%{search}%")));
        }

        if (!string.IsNullOrWhiteSpace(filter.Category))
        {
            var category = filter.Category.Trim();
            query = query.Where(c => c.Skills.Any(s => s.Category == category));
        }

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(c => c.UpdatedAt ?? c.CreatedAt)
            .ThenBy(c => c.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .Select(c => new CandidateSearchItem
            {
                Id = c.Id,
                FullName = c.FullName,
                PhotoUrl = c.PhotoUrl,
                Location = c.Location,
                ExperienceLevel = c.ExperienceLevel,
                TopSkills = c.Skills.OrderBy(s => s.NameRu).Take(3).Select(s => s.NameRu).ToList()
            })
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public void Update(CandidateProfile profile) => _context.CandidateProfiles.Update(profile);
}