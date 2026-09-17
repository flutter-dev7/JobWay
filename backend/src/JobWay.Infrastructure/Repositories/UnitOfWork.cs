using JobWay.Application.Interfaces.Repositories;
using JobWay.Infrastructure.Persistence;
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
        ISkillRepository skills)
    {
        _context = context;
        Users = users;
        CandidateProfiles = candidateProfiles;
        CompanyProfiles = companyProfiles;
        Skills = skills;
    }

    public IUserRepository Users { get; }
    public ICandidateProfileRepository CandidateProfiles { get; }
    public ICompanyProfileRepository CompanyProfiles { get; }
    public ISkillRepository Skills { get; }

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
        => _context.SaveChangesAsync(cancellationToken);
}