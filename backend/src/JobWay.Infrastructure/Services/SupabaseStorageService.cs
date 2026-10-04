using JobWay.Application.Common;
using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Supabase;

namespace JobWay.Infrastructure.Services;

public class SupabaseStorageService : IFileStorageService
{
    private const long SignedUrlExpirySeconds = 60 * 60 * 24 * 365;

    private readonly Client _client;
    private readonly ILogger<SupabaseStorageService> _logger;

    public SupabaseStorageService(IOptions<SupabaseSettings> settings, ILogger<SupabaseStorageService> logger)
    {
        _logger = logger;
        var options = settings.Value;

        if (string.IsNullOrWhiteSpace(options.Url) || string.IsNullOrWhiteSpace(options.ServiceRoleKey))
            throw new InvalidOperationException("Supabase settings (Url/ServiceRoleKey) are not configured");

        _logger.LogInformation("Supabase Storage init. Url={Url}, KeyLength={KeyLength}", options.Url, options.ServiceRoleKey.Length);

        _client = new Client(options.Url, options.ServiceRoleKey, new SupabaseOptions
        {
            AutoRefreshToken = false,
            AutoConnectRealtime = false
        });
    }

    public async Task<string> SaveAsync(string containerName, string fileName, Stream content, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Uploading file {FileName} to bucket {Bucket}", fileName, containerName);

        try
        {
            await using var memoryStream = new MemoryStream();
            await content.CopyToAsync(memoryStream, cancellationToken);
            var bytes = memoryStream.ToArray();

            _logger.LogInformation("File size: {Size} bytes", bytes.Length);

            var bucket = _client.Storage.From(containerName);
            var uploadResult = await bucket.Upload(bytes, fileName, new Supabase.Storage.FileOptions { Upsert = true });

            _logger.LogInformation("Upload result: {Result}", uploadResult);

            var signedUrl = await bucket.CreateSignedUrl(fileName, (int)SignedUrlExpirySeconds);

            _logger.LogInformation("Signed URL: {Url}", signedUrl);

            return signedUrl;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to upload file {FileName} to bucket {Bucket}", fileName, containerName);
            throw;
        }
    }
}