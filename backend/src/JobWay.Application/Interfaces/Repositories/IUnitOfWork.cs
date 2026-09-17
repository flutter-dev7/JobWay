namespace JobWay.Application.Interfaces.Repositories;

public interface IUnitOfWork
{
    IUserRepository Users { get; }
    ICandidateProfileRepository CandidateProfiles { get; }
    ICompanyProfileRepository CompanyProfiles { get; }
    ISkillRepository Skills { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}