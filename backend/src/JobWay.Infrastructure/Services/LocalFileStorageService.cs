using JobWay.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace JobWay.Infrastructure.Services;

public class LocalFileStorageService : IFileStorageService
{
    private readonly string _publicBaseUrl;

    public LocalFileStorageService(IConfiguration configuration)
    {
        _publicBaseUrl = (configuration["Storage:PublicBaseUrl"] ?? string.Empty).TrimEnd('/');
    }

    public async Task<string> SaveAsync(string containerName, string fileName, Stream content, CancellationToken cancellationToken)
    {
        var safeName = Path.GetFileName(fileName);
        var folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", containerName);
        Directory.CreateDirectory(folder);

        var filePath = Path.Combine(folder, safeName);
        await using var fileStream = new FileStream(filePath, FileMode.Create);
        await content.CopyToAsync(fileStream, cancellationToken);

        return $"{_publicBaseUrl}/uploads/{containerName}/{safeName}";
    }

    public Task DeleteAsync(string containerName, string existingFileUrl, CancellationToken cancellationToken)
    {
        try
        {
            var marker = $"/uploads/{containerName}/";
            var index = existingFileUrl.IndexOf(marker, StringComparison.Ordinal);
            if (index < 0) return Task.CompletedTask;

            var fileName = Path.GetFileName(existingFileUrl[(index + marker.Length)..]);
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", containerName, fileName);

            if (File.Exists(filePath))
                File.Delete(filePath);
        }
        catch
        {
            // старый файл не критичен, как и в Supabase-реализации
        }

        return Task.CompletedTask;
    }
}