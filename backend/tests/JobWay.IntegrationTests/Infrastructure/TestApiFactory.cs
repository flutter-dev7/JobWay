using System.Reflection;
using JobWay.Application.Interfaces.Services;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using Microsoft.Extensions.Hosting;

namespace JobWay.IntegrationTests.Infrastructure;

public sealed class TestApiFactory : WebApplicationFactory<Program>
{
    public TestApiFactory(string connectionString)
    {
        // Program.cs читает настройки до сборки приложения, поэтому передаём их
        // через переменные окружения: так они гарантированно попадают в конфигурацию
        SetEnv("ConnectionStrings__DefaultConnection", connectionString);
        SetEnv("JwtSettings__SecretKey", "integration-tests-secret-key-0123456789-abcdef");
        SetEnv("JwtSettings__Issuer", "JobWay");
        SetEnv("JwtSettings__Audience", "JobWayClient");
        SetEnv("JwtSettings__AccessTokenExpirationMinutes", "60");
        SetEnv("JwtSettings__RefreshTokenExpirationDays", "14");
        SetEnv("Storage__Provider", "Local");
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        // Окружение Testing: файл appsettings.Development.json с рабочими ключами не загружается
        builder.UseEnvironment("Testing");

        builder.ConfigureTestServices(services =>
        {
            // Фоновые задачи проекта в тестах не нужны: они бы по таймеру ходили в ту же базу
            var backgroundJobs = services
                .Where(d => d.ServiceType == typeof(IHostedService)
                            && d.ImplementationType?.Namespace == "JobWay.Infrastructure.BackgroundJobs")
                .ToList();

            foreach (var descriptor in backgroundJobs)
                services.Remove(descriptor);

            // Внешние сервисы заменяются заглушками: письма и push наружу не уходят, файлы на диск не пишутся
            ReplaceWithNoOp<IEmailService>(services);
            ReplaceWithNoOp<IPushNotificationService>(services);
            ReplaceWithNoOp<IFileStorageService>(services);
        });
    }

    private static void ReplaceWithNoOp<T>(IServiceCollection services) where T : class
    {
        services.RemoveAll<T>();
        services.AddSingleton(DispatchProxy.Create<T, NoOpProxy>());
    }

    private static void SetEnv(string name, string value) => Environment.SetEnvironmentVariable(name, value);
}

// Универсальная заглушка интерфейса: любой метод ничего не делает и возвращает пустое значение
public class NoOpProxy : DispatchProxy
{
    protected override object? Invoke(MethodInfo? targetMethod, object?[]? args)
    {
        var returnType = targetMethod?.ReturnType ?? typeof(void);

        if (returnType == typeof(void)) return null;
        if (returnType == typeof(Task)) return Task.CompletedTask;

        if (returnType.IsGenericType && returnType.GetGenericTypeDefinition() == typeof(Task<>))
        {
            var resultType = returnType.GetGenericArguments()[0];
            var value = resultType.IsValueType ? Activator.CreateInstance(resultType) : null;

            return typeof(Task)
                .GetMethod(nameof(Task.FromResult))!
                .MakeGenericMethod(resultType)
                .Invoke(null, [value]);
        }

        return returnType.IsValueType ? Activator.CreateInstance(returnType) : null;
    }
}