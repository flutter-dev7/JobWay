using JobWay.Application.Interfaces.Repositories;
using JobWay.Infrastructure.Persistence.Data;

namespace JobWay.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;

    public UnitOfWork(
        AppDbContext context,
        IUserRepository users,
        ICandidateProfileRepository candidateProfiles,
        ICompanyProfileRepository companyProfiles,
        ISkillRepository skills,
        IVacancyRepository vacancies,
        IJobApplicationRepository jobApplications,
        INotificationRepository notifications,
        ISavedVacancyRepository savedVacancies)
    {
        _context = context;
        Users = users;
        CandidateProfiles = candidateProfiles;
        CompanyProfiles = companyProfiles;
        Skills = skills;
        Vacancies = vacancies;
        JobApplications = jobApplications;
        Notifications = notifications;
        SavedVacancies = savedVacancies;
    }

    public IUserRepository Users { get; }
    public ICandidateProfileRepository CandidateProfiles { get; }
    public ICompanyProfileRepository CompanyProfiles { get; }
    public ISkillRepository Skills { get; }
    public IVacancyRepository Vacancies { get; }
    public IJobApplicationRepository JobApplications { get; }
    public INotificationRepository Notifications { get; }
    public ISavedVacancyRepository SavedVacancies { get; }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
        => _context.SaveChangesAsync(cancellationToken);
}