using JobWay.Domain.Entities;

namespace JobWay.Application.Interfaces.Repositories;

public interface IDeviceTokenRepository
{
    Task<DeviceToken?> GetByTokenAsync(string token, CancellationToken cancellationToken);
    Task<List<string>> GetTokensByUserIdAsync(Guid userId, CancellationToken cancellationToken);
    void Add(DeviceToken deviceToken);
    void Update(DeviceToken deviceToken);
}