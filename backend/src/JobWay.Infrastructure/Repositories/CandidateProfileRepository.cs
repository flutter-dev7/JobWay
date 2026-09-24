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
        => _context.CandidateProfiles
            .Include(p => p.Skills)
            .FirstOrDefaultAsync(p => p.UserId == userId, cancellationToken);

    public Task<List<CandidateProfile>> GetAllAsync(CancellationToken cancellationToken)
        => _context.CandidateProfiles.ToListAsync(cancellationToken);

    public void Update(CandidateProfile profile) => _context.CandidateProfiles.Update(profile);
}