using System.Net;
using System.Net.Http.Json;
using JobWay.Application.Common;
using JobWay.IntegrationTests.Infrastructure;

namespace JobWay.IntegrationTests;

[Collection(ApiCollection.Name)]
public class InvitationFlowTests(ApiFixture api)
{
    private sealed record Scenario(TestUser Employer, Guid VacancyId, TestUser Candidate, Guid CandidateProfileId);

    // Верифицированный работодатель с активной вакансией и кандидат с открытым профилем
    private async Task<Scenario> PrepareAsync(bool candidateVisible = true)
    {
        var employer = await api.RegisterAsync("Employer");
        await api.VerifyCompanyAsync(employer);
        var vacancyId = await api.CreateAndPublishVacancyAsync(employer);

        var (candidate, profileId) = await NewCandidateAsync(candidateVisible);

        return new Scenario(employer, vacancyId, candidate, profileId);
    }

    private async Task<(TestUser Candidate, Guid ProfileId)> NewCandidateAsync(bool visible = true)
    {
        var candidate = await api.RegisterAsync("Candidate");
        if (visible) await api.MakeVisibleToEmployersAsync(candidate);

        return (candidate, await api.GetCandidateProfileIdAsync(candidate));
    }

    private static Task<HttpResponseMessage> InviteAsync(TestUser employer, Guid vacancyId, Guid candidateProfileId)
        => employer.Client.PostAsJsonAsync("api/invitations", new { vacancyId, candidateProfileId, message = "Ждём вас на собеседование" });

    private static async Task<Guid> PendingInvitationIdAsync(TestUser candidate)
    {
        var data = await (await candidate.Client.GetAsync("api/invitations/my?status=Pending")).DataAsync();
        var items = data.Prop("items");

        Assert.Equal(1, items.GetArrayLength());
        return items[0].GuidOf("id");
    }

    [Fact]
    public async Task Invite_ThenAccept_CreatesApplication()
    {
        var s = await PrepareAsync();

        await (await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId)).ExpectAsync(HttpStatusCode.OK);

        var invitationId = await PendingInvitationIdAsync(s.Candidate);
        await (await s.Candidate.Client.PostAsync($"api/invitations/{invitationId}/accept", null)).ExpectAsync(HttpStatusCode.OK);

        // Принятое приглашение стало обычным откликом, который видит работодатель
        var applications = await (await s.Employer.Client.GetAsync($"api/vacancies/{s.VacancyId}/applications")).DataAsync();
        Assert.Equal(1, applications.Prop("items").GetArrayLength());

        var pending = await (await s.Candidate.Client.GetAsync("api/invitations/my?status=Pending")).DataAsync();
        Assert.Equal(0, pending.Prop("items").GetArrayLength());
    }

    [Fact]
    public async Task Invite_CandidateWithHiddenProfile_ReturnsForbidden()
    {
        var s = await PrepareAsync(candidateVisible: false);

        var response = await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId);

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Invite_Twice_ReturnsConflict()
    {
        var s = await PrepareAsync();

        await (await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId)).ExpectAsync(HttpStatusCode.OK);
        var second = await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId);

        await second.ExpectAsync(HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task Invite_CandidateWhoAlreadyApplied_ReturnsConflict_AndVacancyIsReportedAsBlocked()
    {
        var s = await PrepareAsync();
        await (await api.ApplyAsync(s.Candidate, s.VacancyId)).ExpectAsync(HttpStatusCode.OK);

        var response = await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId);
        await response.ExpectAsync(HttpStatusCode.Conflict);

        var blocked = await (await s.Employer.Client.GetAsync($"api/invitations/candidate/{s.CandidateProfileId}/blocked")).DataAsync();
        var entry = blocked.EnumerateArray().Single(b => b.GuidOf("vacancyId") == s.VacancyId);

        Assert.Equal("Applied", entry.Text("reason"));
    }

    [Fact]
    public async Task Decline_BlocksReinvitation()
    {
        var s = await PrepareAsync();
        await (await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId)).ExpectAsync(HttpStatusCode.OK);

        var invitationId = await PendingInvitationIdAsync(s.Candidate);
        var declined = await (await s.Candidate.Client.PostAsync($"api/invitations/{invitationId}/decline", null)).DataAsync();
        Assert.Equal("Declined", declined.Text("status"));

        var again = await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId);
        await again.ExpectAsync(HttpStatusCode.Conflict);

        var blocked = await (await s.Employer.Client.GetAsync($"api/invitations/candidate/{s.CandidateProfileId}/blocked")).DataAsync();
        Assert.Equal("Declined", blocked.EnumerateArray().Single(b => b.GuidOf("vacancyId") == s.VacancyId).Text("reason"));
    }

    [Fact]
    public async Task Invite_BeyondFreeDailyLimit_ReturnsForbidden()
    {
        var s = await PrepareAsync();

        // Первый кандидат из сценария плюс остальные до лимита
        await (await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId)).ExpectAsync(HttpStatusCode.OK);

        for (var i = 1; i < TierRules.FreeInvitationsPerDay; i++)
        {
            var (_, profileId) = await NewCandidateAsync();
            await (await InviteAsync(s.Employer, s.VacancyId, profileId)).ExpectAsync(HttpStatusCode.OK);
        }

        var (_, extraProfileId) = await NewCandidateAsync();
        var response = await InviteAsync(s.Employer, s.VacancyId, extraProfileId);

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }

    [Fact]
    public async Task Accept_InvitationOfAnotherCandidate_ReturnsNotFound()
    {
        var s = await PrepareAsync();
        await (await InviteAsync(s.Employer, s.VacancyId, s.CandidateProfileId)).ExpectAsync(HttpStatusCode.OK);
        var invitationId = await PendingInvitationIdAsync(s.Candidate);

        var stranger = await api.RegisterAsync("Candidate");
        var response = await stranger.Client.PostAsync($"api/invitations/{invitationId}/accept", null);

        await response.ExpectAsync(HttpStatusCode.NotFound);
    }
}