using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface ISkillRepository
{
    Task<List<Skill>> GetAllAsync(CancellationToken cancellationToken);
    Task<bool> ExistsByNameAsync(string nameRu, CancellationToken cancellationToken);
    void Add(Skill skill);
}