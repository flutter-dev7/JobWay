using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly AppDbContext _context;

    public UserRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<User?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.Id == id, cancellationToken);

    public Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.Email == email, cancellationToken);
    
    public Task<List<Guid>> GetAdminUserIdsAsync(CancellationToken cancellationToken)
        => _context.Users
            .Where(u => u.Role == UserRole.Admin && u.IsActive)
            .Select(u => u.Id)
            .ToListAsync(cancellationToken);

    public Task<User?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken)
        => _context.Users.FirstOrDefaultAsync(u => u.RefreshToken == refreshToken, cancellationToken);

    public Task<bool> ExistsAsync(string email, CancellationToken cancellationToken)
        => _context.Users.AnyAsync(u => u.Email == email, cancellationToken);

    public Task<List<User>> GetAllAsync(CancellationToken cancellationToken)
        => _context.Users.ToListAsync(cancellationToken);

    public async Task AddAsync(User user, CancellationToken cancellationToken)
        => await _context.Users.AddAsync(user, cancellationToken);

    public void Update(User user) => _context.Users.Update(user);
}