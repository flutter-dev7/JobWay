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

    public void Add(JobApplication application) => _context.JobApplications.Add(application);
    public void Update(JobApplication application) => _context.JobApplications.Update(application);
}