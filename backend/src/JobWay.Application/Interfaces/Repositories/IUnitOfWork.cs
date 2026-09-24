namespace JobWay.Application.Interfaces.Repositories;

public interface IUnitOfWork
{
    IUserRepository Users { get; }
    ICandidateProfileRepository CandidateProfiles { get; }
    ICompanyProfileRepository CompanyProfiles { get; }
    ISkillRepository Skills { get; }
    IVacancyRepository Vacancies { get; }
    IJobApplicationRepository JobApplications { get; }
    INotificationRepository Notifications { get; }
    ISavedVacancyRepository SavedVacancies { get; }
    IDeviceTokenRepository DeviceTokens { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}