using JobWay.Application.DTOs.JobApplication.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class JobApplicationRepository : IJobApplicationRepository
{
    private readonly AppDbContext _context;

    public JobApplicationRepository(AppDbContext context)
    {
        _context = context;
    }

    private IQueryable<JobApplication> WithIncludes()
        => _context.JobApplications
            .Include(a => a.CandidateProfile).ThenInclude(c => c.Skills)
            .Include(a => a.CandidateProfile).ThenInclude(c => c.User)
            .Include(a => a.Vacancy).ThenInclude(v => v.CompanyProfile).ThenInclude(c => c.User)
            .Include(a => a.Vacancy).ThenInclude(v => v.RequiredSkills);
    
    public Task<JobApplication?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => WithIncludes().FirstOrDefaultAsync(a => a.Id == id, cancellationToken);

    public Task<bool> ExistsAsync(Guid candidateProfileId, Guid vacancyId, CancellationToken cancellationToken)
        => _context.JobApplications.AnyAsync(a => a.CandidateProfileId == candidateProfileId && a.VacancyId == vacancyId, cancellationToken);

    public Task<List<JobApplication>> GetByVacancyIdAsync(Guid vacancyId, CancellationToken cancellationToken)
        => WithIncludes()
            .Where(a => a.VacancyId == vacancyId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<List<JobApplication>> GetByCandidateProfileIdAsync(Guid candidateProfileId, CancellationToken cancellationToken)
        => WithIncludes()
            .Where(a => a.CandidateProfileId == candidateProfileId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync(cancellationToken);
    
    public Task<List<JobApplication>> GetByCompanyProfileIdAsync(Guid companyProfileId, CancellationToken cancellationToken)
        => WithIncludes()
            .Where(a => a.Vacancy.CompanyProfileId == companyProfileId)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync(cancellationToken);
    
    public Task<bool> ExistsForCandidateAndCompanyAsync(Guid candidateProfileId, Guid companyProfileId, CancellationToken cancellationToken)
        => _context.JobApplications.AnyAsync(a => a.CandidateProfileId == candidateProfileId && a.Vacancy.CompanyProfileId == companyProfileId, cancellationToken);
    
    public Task<JobApplication?> GetWithParticipantsAsync(Guid id, CancellationToken cancellationToken)
        => _context.JobApplications
            .Include(a => a.CandidateProfile)
            .Include(a => a.Vacancy)
            .ThenInclude(v => v.CompanyProfile)
            .FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
    
    public Task<List<JobApplication>> GetCompletedWithoutReminderCheckAsync(DateTime updatedBefore, CancellationToken cancellationToken)
        => _context.JobApplications
            .Include(a => a.CandidateProfile)
            .Include(a => a.Vacancy)
            .ThenInclude(v => v.CompanyProfile)
            .Where(a => (a.Status == ApplicationStatus.Accepted || a.Status == ApplicationStatus.Rejected)
                        && a.UpdatedAt <= updatedBefore)
            .ToListAsync(cancellationToken);
    
    public async Task<(List<JobApplication> Items, int TotalCount)> GetPagedByCandidateProfileIdAsync(
        Guid candidateProfileId, ApplicationFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = WithIncludes().Where(a => a.CandidateProfileId == candidateProfileId);

        if (filter.Status is not null)
            query = query.Where(a => a.Status == filter.Status);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(a => a.CreatedAt)
            .ThenBy(a => a.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .AsSplitQuery()
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
    
    public async Task<(List<JobApplication> Items, int TotalCount)> GetPagedByVacancyIdAsync(
        Guid vacancyId, ApplicationFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = WithIncludes().Where(a => a.VacancyId == vacancyId);

        if (filter.Status is not null)
            query = query.Where(a => a.Status == filter.Status);

        var totalCount = await query.CountAsync(cancellationToken);

        var ordered = string.Equals(filter.SortBy, "matchScore", StringComparison.OrdinalIgnoreCase)
            ? query.OrderByDescending(a => a.MatchScore).ThenByDescending(a => a.CreatedAt)
            : query.OrderByDescending(a => a.CreatedAt);

        var items = await ordered
            .ThenBy(a => a.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .AsSplitQuery()
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public Task<List<Guid>> GetVacancyIdsByCandidateProfileIdAsync(Guid candidateProfileId, CancellationToken cancellationToken)
        => _context.JobApplications
            .Where(a => a.CandidateProfileId == candidateProfileId)
            .Select(a => a.VacancyId)
            .ToListAsync(cancellationToken);
    
    public Task<List<JobApplication>> GetByIdsWithParticipantsAsync(List<Guid> ids, CancellationToken cancellationToken)
        => _context.JobApplications
            .Include(a => a.CandidateProfile).ThenInclude(c => c.User)
            .Include(a => a.Vacancy).ThenInclude(v => v.CompanyProfile).ThenInclude(c => c.User)
            .Where(a => ids.Contains(a.Id))
            .ToListAsync(cancellationToken);

    public void Add(JobApplication application) => _context.JobApplications.Add(application);
    public void Update(JobApplication application) => _context.JobApplications.Update(application);
}