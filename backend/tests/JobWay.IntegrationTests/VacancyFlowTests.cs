using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using JobWay.Application.Common;
using JobWay.IntegrationTests.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace JobWay.IntegrationTests;

[Collection(ApiCollection.Name)]
public class VacancyFlowTests(ApiFixture api)
{
    // Поиск в ленте по уникальному названию
    private static async Task<List<JsonElement>> SearchFeedAsync(TestUser user, string title)
    {
        var data = await (await user.Client.GetAsync($"api/vacancies?search={Uri.EscapeDataString(title)}&pageSize=50")).DataAsync();
        return data.Prop("items").EnumerateArray().ToList();
    }

    private async Task<TestUser> RegisterVerifiedEmployerAsync()
    {
        var employer = await api.RegisterAsync("Employer");
        await api.VerifyCompanyAsync(employer);

        return employer;
    }

    [Fact]
    public async Task FullFlow_PublishApplyAndChangeStatus_Works()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var candidate = await api.RegisterAsync("Candidate");
        var title = $"Flutter Developer {Guid.NewGuid():N}";

        var vacancyId = await api.CreateVacancyAsync(employer, title);

        // Черновик в ленте кандидатов не виден
        Assert.Empty(await SearchFeedAsync(candidate, title));

        await (await api.PublishVacancyAsync(employer, vacancyId)).ExpectAsync(HttpStatusCode.OK);
        Assert.Single(await SearchFeedAsync(candidate, title));

        var application = await (await api.ApplyAsync(candidate, vacancyId)).DataAsync();
        var applicationId = application.GuidOf("id");
        Assert.Equal("Pending", application.Text("status"));

        var applications = await (await employer.Client.GetAsync($"api/vacancies/{vacancyId}/applications")).DataAsync();
        Assert.Equal(1, applications.Prop("items").GetArrayLength());

        var updated = await (await employer.Client.PutAsJsonAsync($"api/applications/{applicationId}/status", new { status = "Interview" })).DataAsync();
        Assert.Equal("Interview", updated.Text("status"));

        var mine = await (await candidate.Client.GetAsync("api/applications/my")).DataAsync();
        Assert.Equal("Interview", mine.Prop("items")[0].Text("status"));

        // Кандидат получил уведомление о смене статуса
        var unread = await (await candidate.Client.GetAsync("api/notifications/unread-count")).DataAsync();
        Assert.True(unread.GetInt32() >= 1);
    }

    [Fact]
    public async Task Publish_ByUnverifiedCompany_ReturnsForbidden()
    {
        var employer = await api.RegisterAsync("Employer");
        var vacancyId = await api.CreateVacancyAsync(employer);

        var response = await api.PublishVacancyAsync(employer, vacancyId);

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Publish_BeyondFreeTierLimit_ReturnsForbidden()
    {
        var employer = await RegisterVerifiedEmployerAsync();

        for (var i = 0; i < TierRules.FreeActiveVacancyLimit; i++)
            await api.CreateAndPublishVacancyAsync(employer);

        var extra = await api.CreateVacancyAsync(employer);
        var response = await api.PublishVacancyAsync(employer, extra);

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Apply_Twice_ReturnsConflict()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var candidate = await api.RegisterAsync("Candidate");
        var vacancyId = await api.CreateAndPublishVacancyAsync(employer);

        await (await api.ApplyAsync(candidate, vacancyId)).ExpectAsync(HttpStatusCode.OK);
        var second = await api.ApplyAsync(candidate, vacancyId);

        await second.ExpectAsync(HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task Apply_ToDraftVacancy_ReturnsBadRequest()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var candidate = await api.RegisterAsync("Candidate");
        var vacancyId = await api.CreateVacancyAsync(employer);

        var response = await api.ApplyAsync(candidate, vacancyId);

        await response.ExpectAsync(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task UpdateStatus_ByAnotherEmployer_ReturnsForbidden()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var stranger = await RegisterVerifiedEmployerAsync();
        var candidate = await api.RegisterAsync("Candidate");
        var vacancyId = await api.CreateAndPublishVacancyAsync(employer);

        var application = await (await api.ApplyAsync(candidate, vacancyId)).DataAsync();

        var response = await stranger.Client.PutAsJsonAsync(
            $"api/applications/{application.GuidOf("id")}/status",
            new { status = "Accepted" });

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Close_RemovesVacancyFromFeed()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var candidate = await api.RegisterAsync("Candidate");
        var title = $"Closing soon {Guid.NewGuid():N}";
        var vacancyId = await api.CreateAndPublishVacancyAsync(employer, title);

        Assert.Single(await SearchFeedAsync(candidate, title));

        await (await employer.Client.PostAsync($"api/vacancies/{vacancyId}/close", null)).ExpectAsync(HttpStatusCode.OK);

        Assert.Empty(await SearchFeedAsync(candidate, title));
    }

    [Fact]
    public async Task Renew_ResetsExpiryToThirtyDaysFromNow()
    {
        var employer = await RegisterVerifiedEmployerAsync();
        var vacancyId = await api.CreateAndPublishVacancyAsync(employer);

        // Имитируем вакансию, которой осталось два дня
        await api.ExecuteDbAsync(db => db.Vacancies
            .Where(v => v.Id == vacancyId)
            .ExecuteUpdateAsync(s => s.SetProperty(v => v.ExpiresAt, (DateTime?)DateTime.UtcNow.AddDays(2))));

        var renewed = await (await employer.Client.PostAsync($"api/vacancies/{vacancyId}/renew", null)).DataAsync();

        var expected = DateTime.UtcNow.AddDays(VacancyRules.LifetimeDays);
        Assert.InRange(
            renewed.Prop("expiresAt").GetDateTime(),
            expected.AddMinutes(-2),
            expected.AddMinutes(2));
    }
}