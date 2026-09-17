using JobWay.Domain.Common;

namespace JobWay.Application.Interfaces.Repositories;

public interface IUnitOfWork
{
    IRepository<T> Repository<T>() where T : BaseEntity;
    Task AddAsync<T>(T entity, CancellationToken cancellationToken) where T : BaseEntity;
    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}