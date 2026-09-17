using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
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

    public Task<CompanyProfile?> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.CompanyProfiles.FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

    public void Update(CompanyProfile profile) => _context.CompanyProfiles.Update(profile);
}