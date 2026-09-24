using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class DeviceTokenRepository : IDeviceTokenRepository
{
    private readonly AppDbContext _context;

    public DeviceTokenRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<DeviceToken?> GetByTokenAsync(string token, CancellationToken cancellationToken)
        => _context.DeviceTokens.FirstOrDefaultAsync(d => d.Token == token, cancellationToken);

    public Task<List<string>> GetTokensByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.DeviceTokens.Where(d => d.UserId == userId).Select(d => d.Token).ToListAsync(cancellationToken);

    public void Add(DeviceToken deviceToken) => _context.DeviceTokens.Add(deviceToken);
    public void Update(DeviceToken deviceToken) => _context.DeviceTokens.Update(deviceToken);
}