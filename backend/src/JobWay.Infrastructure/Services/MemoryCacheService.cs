using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Caching.Memory;

namespace JobWay.Infrastructure.Services;

public class MemoryCacheService : ICacheService
{
    private readonly IMemoryCache _cache;

    public MemoryCacheService(IMemoryCache cache)
    {
        _cache = cache;
    }

    public Task SetAsync(string key, string value, TimeSpan expiry, CancellationToken ct = default)
    {
        _cache.Set(key, value, expiry);
        return Task.CompletedTask;
    }

    public Task<string?> GetAsync(string key, CancellationToken ct = default)
        => Task.FromResult(_cache.TryGetValue(key, out string? value) ? value : null);

    public Task<bool> ExistsAsync(string key, CancellationToken ct = default)
        => Task.FromResult(_cache.TryGetValue(key, out _));

    public Task RemoveAsync(string key, CancellationToken ct = default)
    {
        _cache.Remove(key);
        return Task.CompletedTask;
    }
}