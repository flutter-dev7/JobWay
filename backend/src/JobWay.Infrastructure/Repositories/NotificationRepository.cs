using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly AppDbContext _context;

    public NotificationRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<Notification?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
        => _context.Notifications.FirstOrDefaultAsync(n => n.Id == id, cancellationToken);

    public Task<List<Notification>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken)
        => _context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(cancellationToken);

    public void Add(Notification notification) => _context.Notifications.Add(notification);
    public void Update(Notification notification) => _context.Notifications.Update(notification);
}