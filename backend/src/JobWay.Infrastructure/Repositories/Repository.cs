using System.Linq.Expressions;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Common;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class Repository<T> : IRepository<T> where T : BaseEntity
{
    private readonly DbSet<T> _dbSet;

    public Repository(AppDbContext context)
    {
        _dbSet = context.Set<T>();
    }

    public Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _dbSet.FirstOrDefaultAsync(e => e.Id == id, cancellationToken);

    public Task<T?> FirstOrDefaultAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken)
        => _dbSet.FirstOrDefaultAsync(predicate, cancellationToken);

    public Task<bool> ExistsAsync(Expression<Func<T, bool>> predicate, CancellationToken cancellationToken)
        => _dbSet.AnyAsync(predicate, cancellationToken);

    public Task<List<T>> GetAllAsync(CancellationToken cancellationToken)
        => _dbSet.ToListAsync(cancellationToken);

    public void Add(T entity) => _dbSet.Add(entity);
    public void Update(T entity) => _dbSet.Update(entity);
    public void Remove(T entity) => _dbSet.Remove(entity);
}