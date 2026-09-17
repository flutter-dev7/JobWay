namespace JobWay.Application.Interfaces.Services;

public interface ICacheService
{
    Task SetAsync(string key, string value, TimeSpan expiry, CancellationToken ct = default);
    Task<string?> GetAsync(string key, CancellationToken ct = default);
    Task<bool> ExistsAsync(string key, CancellationToken ct = default);
    Task RemoveAsync(string key, CancellationToken ct = default);
}