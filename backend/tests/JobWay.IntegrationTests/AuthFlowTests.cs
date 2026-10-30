using System.Net;
using System.Net.Http.Json;
using JobWay.IntegrationTests.Infrastructure;

namespace JobWay.IntegrationTests;

[Collection(ApiCollection.Name)]
public class AuthFlowTests(ApiFixture api)
{
    [Fact]
    public async Task Register_ThenLogin_ReturnsTokensAndProfile()
    {
        var user = await api.RegisterAsync("Candidate", "Ismoil Zaynalov");

        var login = await api.CreateClient().PostAsJsonAsync("api/auth/login", new { email = user.Email, password = user.Password });
        var data = await login.DataAsync();

        Assert.False(string.IsNullOrEmpty(data.Text("accessToken")));
        Assert.False(string.IsNullOrEmpty(data.Text("refreshToken")));
        Assert.Equal("Candidate", data.Text("role"));

        var profile = await (await user.Client.GetAsync("api/candidate-profile/me")).DataAsync();
        Assert.Equal("Ismoil Zaynalov", profile.Text("fullName"));
    }

    [Fact]
    public async Task Register_WithoutVerifiedEmail_ReturnsBadRequest()
    {
        var response = await api.CreateClient().PostAsJsonAsync("api/auth/register", new
        {
            email = $"nocode-{Guid.NewGuid():N}@test.local",
            password = "Passw0rd!123",
            confirmPassword = "Passw0rd!123",
            role = "Candidate",
            name = "No Code"
        });

        await response.ExpectAsync(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task SendRegistrationCode_ForExistingEmail_ReturnsConflict()
    {
        var user = await api.RegisterAsync("Candidate");

        var response = await api.CreateClient().PostAsJsonAsync("api/auth/send-registration-code", new { email = user.Email });

        await response.ExpectAsync(HttpStatusCode.Conflict);
    }

    [Fact]
    public async Task Login_WithWrongPassword_ReturnsUnauthorized()
    {
        var user = await api.RegisterAsync("Candidate");

        var response = await api.CreateClient().PostAsJsonAsync("api/auth/login", new { email = user.Email, password = "wrong-password" });

        await response.ExpectAsync(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ProtectedEndpoint_WithoutToken_ReturnsUnauthorized()
    {
        var response = await api.CreateClient().GetAsync("api/vacancies");

        await response.ExpectAsync(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task RefreshToken_RotatesTokens_AndRejectsTheOldOne()
    {
        var user = await api.RegisterAsync("Candidate");
        var client = api.CreateClient();

        var refreshed = await (await client.PostAsJsonAsync("api/auth/refresh-token", new { refreshToken = user.RefreshToken })).DataAsync();

        Assert.NotEqual(user.RefreshToken, refreshed.Text("refreshToken"));

        var reuse = await client.PostAsJsonAsync("api/auth/refresh-token", new { refreshToken = user.RefreshToken });
        await reuse.ExpectAsync(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Candidate_CannotCreateVacancy_ReturnsForbidden()
    {
        var candidate = await api.RegisterAsync("Candidate");

        var response = await candidate.Client.PostAsJsonAsync("api/vacancies", new { title = "Нельзя" });

        await response.ExpectAsync(HttpStatusCode.Forbidden);
    }
}