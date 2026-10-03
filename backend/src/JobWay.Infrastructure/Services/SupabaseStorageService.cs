using JobWay.Application.Common;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Options;
using Supabase;

namespace JobWay.Infrastructure.Services;

public class SupabaseStorageService : IFileStorageService
{
    private const long SignedUrlExpirySeconds = 60 * 60 * 24 * 365; // 1 год

    private readonly Client _client;

    public SupabaseStorageService(IOptions<SupabaseSettings> settings)
    {
        var options = settings.Value;
        _client = new Client(options.Url, options.ServiceRoleKey, new SupabaseOptions
        {
            AutoRefreshToken = false,
            AutoConnectRealtime = false
        });
    }

    public async Task<string> SaveAsync(string containerName, string fileName, Stream content, CancellationToken cancellationToken)
    {
        await using var memoryStream = new MemoryStream();
        await content.CopyToAsync(memoryStream, cancellationToken);
        var bytes = memoryStream.ToArray();

        var bucket = _client.Storage.From(containerName);
        await bucket.Upload(bytes, fileName, new Supabase.Storage.FileOptions { Upsert = true });

        return await bucket.CreateSignedUrl(fileName, (int)SignedUrlExpirySeconds);
    }
}