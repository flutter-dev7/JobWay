using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class SkillRepository : ISkillRepository
{
    private readonly AppDbContext _context;

    public SkillRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<Skill>> GetAllAsync(CancellationToken cancellationToken)
        => _context.Skills.ToListAsync(cancellationToken);

    public Task<bool> ExistsByNameAsync(string nameRu, CancellationToken cancellationToken)
        => _context.Skills.AnyAsync(s => s.NameRu == nameRu, cancellationToken);

    public void Add(Skill skill) => _context.Skills.Add(skill);
}