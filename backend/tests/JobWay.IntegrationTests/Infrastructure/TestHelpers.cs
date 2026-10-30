using System.Data.Common;
using System.Net;
using System.Text.Json;

namespace JobWay.IntegrationTests.Infrastructure;

// Подключение к тестовой базе. Тесты удаляют и создают её заново, поэтому защита от ошибки обязательна
public static class TestDatabase
{
    private static readonly string[] LocalHosts = ["localhost", "127.0.0.1", "::1"];

    // Берёт JOBWAY_TEST_DB, а если переменной нет, строку из appsettings.Development.json
    // API-проекта с заменой имени базы на jobway_test (пароль в тестах хранить не нужно)
    public static string ResolveConnectionString()
    {
        var connectionString = Environment.GetEnvironmentVariable("JOBWAY_TEST_DB");

        if (string.IsNullOrWhiteSpace(connectionString))
            connectionString = DeriveFromApiSettings();

        var builder = new DbConnectionStringBuilder { ConnectionString = connectionString };
        var database = builder.TryGetValue("Database", out var databaseValue) ? databaseValue?.ToString() : null;
        var host = builder.TryGetValue("Host", out var hostValue) ? hostValue?.ToString() : null;

        if (string.IsNullOrWhiteSpace(database) || !database.EndsWith("_test", StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException(
                $"Имя тестовой базы должно заканчиваться на «_test», сейчас: «{database}». " +
                "Тесты полностью пересоздают базу, поэтому рабочую базу использовать нельзя.");

        if (host is null || !LocalHosts.Contains(host, StringComparer.OrdinalIgnoreCase))
            throw new InvalidOperationException(
                $"Интеграционные тесты запускаются только на локальном PostgreSQL, сейчас хост: «{host}».");

        return connectionString;
    }

    private static string DeriveFromApiSettings()
    {
        var file = FindApiSettingsFile()
            ?? throw new InvalidOperationException(
                "Не найден src/JobWay.API/appsettings.Development.json. " +
                "Задайте строку подключения в переменной JOBWAY_TEST_DB " +
                "(например, Host=localhost;Port=5432;Database=jobway_test;Username=postgres;Password=...).");

        var options = new JsonDocumentOptions { CommentHandling = JsonCommentHandling.Skip, AllowTrailingCommas = true };
        using var document = JsonDocument.Parse(File.ReadAllText(file), options);

        var original = document.RootElement
            .GetProperty("ConnectionStrings")
            .GetProperty("DefaultConnection")
            .GetString()!;

        var builder = new DbConnectionStringBuilder { ConnectionString = original };
        builder["Database"] = "jobway_test";

        return builder.ConnectionString;
    }

    private static string? FindApiSettingsFile()
    {
        var directory = new DirectoryInfo(AppContext.BaseDirectory);

        while (directory is not null)
        {
            var candidate = Path.Combine(directory.FullName, "src", "JobWay.API", "appsettings.Development.json");
            if (File.Exists(candidate)) return candidate;

            directory = directory.Parent;
        }

        return null;
    }
}

public static class HttpAssertions
{
    // Проверяет статус. При несовпадении в сообщении теста сразу видно тело ответа сервера
    public static async Task ExpectAsync(this HttpResponseMessage response, HttpStatusCode expected)
    {
        if (response.StatusCode == expected) return;

        var body = await response.Content.ReadAsStringAsync();
        Assert.Fail(
            $"Ожидался {(int)expected} {expected}, получен {(int)response.StatusCode} {response.StatusCode}." +
            $"{Environment.NewLine}{body}");
    }

    // Возвращает содержимое поля data из ответа вида Result<T>
    public static async Task<JsonElement> DataAsync(this HttpResponseMessage response, HttpStatusCode expected = HttpStatusCode.OK)
    {
        await response.ExpectAsync(expected);

        var body = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(body);

        return document.RootElement.Prop("data").Clone();
    }

    // Поиск свойства без учёта регистра
    public static JsonElement Prop(this JsonElement element, string name)
    {
        if (element.ValueKind == JsonValueKind.Object)
        {
            foreach (var property in element.EnumerateObject())
            {
                if (string.Equals(property.Name, name, StringComparison.OrdinalIgnoreCase))
                    return property.Value;
            }
        }

        throw new KeyNotFoundException($"Свойство «{name}» не найдено в: {element}");
    }

    public static string Text(this JsonElement element, string name) => element.Prop(name).GetString()!;

    public static Guid GuidOf(this JsonElement element, string name) => element.Prop(name).GetGuid();
}