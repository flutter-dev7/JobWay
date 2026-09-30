using JobWay.Application.Interfaces.Repositories;
using JobWay.Domain.Entities;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.EntityFrameworkCore;

namespace JobWay.Infrastructure.Repositories;

public class ChatMessageRepository : IChatMessageRepository
{
    private readonly AppDbContext _context;

    public ChatMessageRepository(AppDbContext context)
    {
        _context = context;
    }

    public Task<List<ChatMessage>> GetByApplicationIdAsync(Guid jobApplicationId, CancellationToken cancellationToken)
        => _context.ChatMessages
            .Where(m => m.JobApplicationId == jobApplicationId)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<List<ChatMessage>> GetByApplicationIdSinceAsync(Guid jobApplicationId, DateTime since, CancellationToken cancellationToken)
        => _context.ChatMessages
            .Where(m => m.JobApplicationId == jobApplicationId && m.CreatedAt > since)
            .OrderBy(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

    public async Task<List<ChatMessage>> GetLatestPerApplicationAsync(List<Guid> jobApplicationIds, CancellationToken cancellationToken)
    {
        var messages = await _context.ChatMessages
            .Where(m => jobApplicationIds.Contains(m.JobApplicationId))
            .OrderByDescending(m => m.CreatedAt)
            .ToListAsync(cancellationToken);

        return messages
            .GroupBy(m => m.JobApplicationId)
            .Select(g => g.First())
            .ToList();
    }

    public Task<int> GetUnreadCountAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken)
        => _context.ChatMessages.CountAsync(
            m => m.JobApplicationId == jobApplicationId && m.SenderUserId != currentUserId && !m.IsRead,
            cancellationToken);

    public async Task MarkAllAsReadAsync(Guid jobApplicationId, Guid currentUserId, CancellationToken cancellationToken)
    {
        var unread = await _context.ChatMessages
            .Where(m => m.JobApplicationId == jobApplicationId && m.SenderUserId != currentUserId && !m.IsRead)
            .ToListAsync(cancellationToken);

        foreach (var message in unread)
            message.IsRead = true;
    }

    public void Add(ChatMessage message) => _context.ChatMessages.Add(message);
}