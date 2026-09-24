namespace JobWay.Application.Interfaces.Services;

public interface IFileStorageService
{
    Task<string> SaveAsync(string containerName, string fileName, Stream content, CancellationToken cancellationToken);
}