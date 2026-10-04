/*using JobWay.Application.Interfaces.Services;

namespace JobWay.Infrastructure.Services;

public class LocalFileStorageService : IFileStorageService
{
    public async Task<string> SaveAsync(string containerName, string fileName, Stream content, CancellationToken cancellationToken)
    {
        var folder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", containerName);
        Directory.CreateDirectory(folder);

        var filePath = Path.Combine(folder, fileName);
        await using var fileStream = new FileStream(filePath, FileMode.Create);
        await content.CopyToAsync(fileStream, cancellationToken);

        return $"/uploads/{containerName}/{fileName}";
    }
}*/