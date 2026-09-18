using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
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
            .Include(a => a.Vacancy).ThenInclude(v => v.CompanyProfile)
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

    public void Add(JobApplication application) => _context.JobApplications.Add(application);
    public void Update(JobApplication application) => _context.JobApplications.Update(application);
}