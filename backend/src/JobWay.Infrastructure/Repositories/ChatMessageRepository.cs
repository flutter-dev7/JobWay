using JobWay.Application.DTOs.Chat.Request;
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

    // Страница истории: самые новые pageSize сообщений (старше before, если задан), в порядке по возрастанию времени
    public async Task<(List<ChatMessage> Items, bool HasMore)> GetPageAsync(
        Guid jobApplicationId, DateTime? before, int pageSize, CancellationToken cancellationToken)
    {
        var query = _context.ChatMessages.Where(m => m.JobApplicationId == jobApplicationId);

        if (before is not null)
            query = query.Where(m => m.CreatedAt < before.Value);

        var items = await query
            .OrderByDescending(m => m.CreatedAt)
            .ThenByDescending(m => m.Id)
            .Take(pageSize + 1)
            .ToListAsync(cancellationToken);

        var hasMore = items.Count > pageSize;
        if (hasMore)
            items.RemoveAt(items.Count - 1);

        items.Reverse();
        return (items, hasMore);
    }

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

    // Последнее сообщение каждой беседы из списка, без загрузки всей истории
    public Task<List<ChatMessage>> GetLastMessagesAsync(List<Guid> jobApplicationIds, CancellationToken cancellationToken)
        => _context.ChatMessages
            .Where(m => jobApplicationIds.Contains(m.JobApplicationId)
                        && m.CreatedAt == _context.ChatMessages
                            .Where(x => x.JobApplicationId == m.JobApplicationId)
                            .Max(x => x.CreatedAt))
            .ToListAsync(cancellationToken);

    public async Task<(List<ChatThreadSummary> Items, int TotalCount)> GetThreadSummariesPagedAsync(
        Guid? candidateProfileId, Guid? companyProfileId, Guid currentUserId,
        ChatThreadsFilterRequest filter, CancellationToken cancellationToken)
    {
        var messages = _context.ChatMessages.AsQueryable();

        if (candidateProfileId is not null)
        {
            var id = candidateProfileId.Value;
            messages = messages.Where(m => m.JobApplication.CandidateProfileId == id);
        }
        else if (companyProfileId is not null)
        {
            var id = companyProfileId.Value;
            messages = messages.Where(m => m.JobApplication.Vacancy.CompanyProfileId == id);
        }
        else
        {
            return ([], 0);
        }

        var grouped = messages
            .GroupBy(m => m.JobApplicationId)
            .Select(g => new
            {
                JobApplicationId = g.Key,
                LastMessageAt = g.Max(m => m.CreatedAt),
                UnreadCount = g.Count(m => m.SenderUserId != currentUserId && !m.IsRead)
            });

        if (filter.UnreadOnly)
            grouped = grouped.Where(s => s.UnreadCount > 0);

        var totalCount = await grouped.CountAsync(cancellationToken);

        var rows = await grouped
            .OrderByDescending(s => s.LastMessageAt)
            .ThenBy(s => s.JobApplicationId)
            .Skip((filter.PageNumber - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        var items = rows
            .Select(r => new ChatThreadSummary(r.JobApplicationId, r.LastMessageAt, r.UnreadCount))
            .ToList();

        return (items, totalCount);
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