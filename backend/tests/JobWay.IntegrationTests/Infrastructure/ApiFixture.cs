using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Enums;
using JobWay.Infrastructure.Persistence.Data;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace JobWay.IntegrationTests.Infrastructure;

public sealed class TestUser
{
    public required Guid UserId { get; init; }
    public required string Email { get; init; }
    public required string Password { get; init; }
    public required string RefreshToken { get; init; }

    // Клиент уже авторизован токеном этого пользователя
    public required HttpClient Client { get; init; }
}

// Все тестовые классы идут в одной коллекции: одно приложение, одна база, тесты по очереди
[CollectionDefinition(ApiCollection.Name)]
public sealed class ApiCollection : ICollectionFixture<ApiFixture>
{
    public const string Name = "Api";
}

public sealed class ApiFixture : IAsyncLifetime
{
    private const string Password = "Passw0rd!123";

    private readonly string _connectionString = TestDatabase.ResolveConnectionString();
    private TestApiFactory? _factory;

    public async Task InitializeAsync()
    {
        // Каждый запуск начинается с чистой базы. Миграции и справочники приложение
        // применит само при первом обращении (так же, как при обычном старте)
        var options = new DbContextOptionsBuilder<AppDbContext>().UseNpgsql(_connectionString).Options;

        await using var db = new AppDbContext(options);
        await db.Database.EnsureDeletedAsync();

        _factory = new TestApiFactory(_connectionString);
    }

    public async Task DisposeAsync()
    {
        if (_factory is not null) await _factory.DisposeAsync();
    }

    public IServiceProvider Services => _factory!.Services;

    public HttpClient CreateClient()
        => _factory!.CreateClient(new WebApplicationFactoryClientOptions { AllowAutoRedirect = false });

    public async Task ExecuteDbAsync(Func<AppDbContext, Task> action)
    {
        using var scope = Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();

        await action(db);
    }

    // ---------- Пользователи ----------

    // Полный путь регистрации: код на почту -> подтверждение -> регистрация.
    // Код письма читаем из кэша приложения, так как письма в тестах никуда не отправляются
    public async Task<TestUser> RegisterAsync(string role, string? name = null)
    {
        var email = $"{role.ToLowerInvariant()}-{Guid.NewGuid():N}@test.local";
        name ??= role == "Employer" ? $"Company {Guid.NewGuid():N}"[..20] : "Test Candidate";

        var client = CreateClient();

        await (await client.PostAsJsonAsync("api/auth/send-registration-code", new { email }))
            .ExpectAsync(HttpStatusCode.OK);

        var code = await ReadRegistrationCodeAsync(email);

        await (await client.PostAsJsonAsync("api/auth/verify-registration-code", new { email, code }))
            .ExpectAsync(HttpStatusCode.OK);

        var data = await (await client.PostAsJsonAsync("api/auth/register", new
        {
            email,
            password = Password,
            confirmPassword = Password,
            role,
            name
        })).DataAsync();

        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", data.Text("accessToken"));

        return new TestUser
        {
            UserId = data.GuidOf("userId"),
            Email = email,
            Password = Password,
            RefreshToken = data.Text("refreshToken"),
            Client = client
        };
    }

    private async Task<string> ReadRegistrationCodeAsync(string email)
    {
        using var scope = Services.CreateScope();
        var cache = scope.ServiceProvider.GetRequiredService<ICacheService>();

        return await cache.GetAsync("registration-code:" + email, CancellationToken.None)
               ?? throw new InvalidOperationException($"Код подтверждения для {email} не найден в кэше");
    }

    // Администратор в тестах не нужен: верификацию компании выставляем прямо в базе
    public Task VerifyCompanyAsync(TestUser employer)
        => ExecuteDbAsync(db => db.CompanyProfiles
            .Where(c => c.UserId == employer.UserId)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.VerificationStatus, VerificationStatus.Verified)));

    // Открывает профиль кандидата для поиска работодателями
    public Task MakeVisibleToEmployersAsync(TestUser candidate)
        => ExecuteDbAsync(db => db.CandidateProfiles
            .Where(c => c.UserId == candidate.UserId)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.IsVisibleToEmployers, true)));

    public async Task<Guid> GetCandidateProfileIdAsync(TestUser candidate)
    {
        var data = await (await candidate.Client.GetAsync("api/candidate-profile/me")).DataAsync();
        return data.GuidOf("id");
    }

    // ---------- Вакансии и отклики ----------

    public async Task<Guid> CreateVacancyAsync(TestUser employer, string? title = null)
    {
        var skills = await (await employer.Client.GetAsync("api/skills")).DataAsync();
        var skillIds = skills.EnumerateArray().Take(2).Select(s => s.GuidOf("id")).ToList();

        var response = await employer.Client.PostAsJsonAsync("api/vacancies", new
        {
            title = title ?? $"Backend developer {Guid.NewGuid():N}",
            description = "Разработка и поддержка backend-сервисов компании",
            responsibilities = "Писать код\nПроводить ревью",
            requirements = "Опыт от года\nЗнание C#",
            employmentType = "FullTime",
            experienceLevel = "Junior",
            paymentType = "Monthly",
            currency = "TJS",
            location = "Душанбе",
            salaryFrom = 3000,
            salaryTo = 5000,
            skillIds
        });

        return (await response.DataAsync()).GuidOf("id");
    }

    public Task<HttpResponseMessage> PublishVacancyAsync(TestUser employer, Guid vacancyId)
        => employer.Client.PostAsync($"api/vacancies/{vacancyId}/publish", null);

    public async Task<Guid> CreateAndPublishVacancyAsync(TestUser employer, string? title = null)
    {
        var vacancyId = await CreateVacancyAsync(employer, title);
        await (await PublishVacancyAsync(employer, vacancyId)).ExpectAsync(HttpStatusCode.OK);

        return vacancyId;
    }

    public Task<HttpResponseMessage> ApplyAsync(TestUser candidate, Guid vacancyId)
        => candidate.Client.PostAsJsonAsync($"api/vacancies/{vacancyId}/applications", new { coverMessage = "Здравствуйте!" });
}