using System.Collections.Concurrent;
using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Common;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;

namespace JobWay.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;
    private readonly ConcurrentDictionary<Type, object> _repositories = new();

    public UnitOfWork(AppDbContext context)
    {
        _context = context;
    }

    public IRepository<T> Repository<T>() where T : BaseEntity
        => (IRepository<T>)_repositories.GetOrAdd(typeof(T), _ => new Repository<T>(_context));

    public async Task AddAsync<T>(T entity, CancellationToken cancellationToken) where T : BaseEntity
        => await _context.Set<T>().AddAsync(entity, cancellationToken);

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken)
        => _context.SaveChangesAsync(cancellationToken);
}