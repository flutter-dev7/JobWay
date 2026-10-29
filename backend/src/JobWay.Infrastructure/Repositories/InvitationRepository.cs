using JobWay.Application.DTOs.Invitation.Request;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class InvitationRepository : IInvitationRepository
{
    private readonly AppDbContext _context;

    public InvitationRepository(AppDbContext context)
    {
        _context = context;
    }

    private IQueryable<Invitation> WithIncludes()
        => _context.Invitations
            .Include(i => i.CompanyProfile)
            .Include(i => i.CandidateProfile)
            .Include(i => i.Vacancy);

    public Task<Invitation?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => WithIncludes().FirstOrDefaultAsync(i => i.Id == id, cancellationToken);

    public Task<bool> ExistsAsync(Guid candidateProfileId, Guid vacancyId, CancellationToken cancellationToken)
        => _context.Invitations.AnyAsync(
            i => i.CandidateProfileId == candidateProfileId && i.VacancyId == vacancyId,
            cancellationToken);

    public Task<int> CountCreatedSinceAsync(Guid companyProfileId, DateTime since, CancellationToken cancellationToken)
        => _context.Invitations.CountAsync(
            i => i.CompanyProfileId == companyProfileId && i.CreatedAt >= since,
            cancellationToken);

    public async Task<(List<Invitation> Items, int TotalCount)> GetPagedByCandidateProfileIdAsync(
        Guid candidateProfileId, InvitationFilterRequest filter, CancellationToken cancellationToken)
    {
        var query = WithIncludes().Where(i => i.CandidateProfileId == candidateProfileId);

        if (filter.Status is not null)
            query = query.Where(i => i.Status == filter.Status);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(i => i.CreatedAt)
            .ThenBy(i => i.Id)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
    
    public Task<List<Invitation>> GetByCandidateAndCompanyAsync(Guid candidateProfileId, Guid companyProfileId, CancellationToken cancellationToken)
        => _context.Invitations
            .Where(i => i.CandidateProfileId == candidateProfileId && i.CompanyProfileId == companyProfileId)
            .ToListAsync(cancellationToken);

    public void Add(Invitation invitation) => _context.Invitations.Add(invitation);
    public void Update(Invitation invitation) => _context.Invitations.Update(invitation);
}