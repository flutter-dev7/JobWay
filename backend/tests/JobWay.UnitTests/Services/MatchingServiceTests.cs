using FluentAssertions;
using JobWay.Application.Services;
using JobWay.Domain.Entities;
using Xunit;

namespace JobWay.UnitTests.Services;

public class MatchingServiceTests
{
    private readonly MatchingService _sut = new();

    [Fact]
    public void Calculate_AllRequiredSkillsMatched_Returns100Percent()
    {
        var csharp = new Skill { Id = Guid.NewGuid(), NameRu = "C#", NameTj = "C#" };
        var dotnet = new Skill { Id = Guid.NewGuid(), NameRu = ".NET", NameTj = ".NET" };

        var result = _sut.Calculate(
            candidateSkills: [csharp, dotnet],
            requiredSkills: [csharp, dotnet]);

        result.ScorePercent.Should().Be(100);
        result.MatchedSkills.Should().HaveCount(2);
        result.MissingSkills.Should().BeEmpty();
    }

    [Fact]
    public void Calculate_NoSkillsMatched_Returns0Percent()
    {
        var csharp = new Skill { Id = Guid.NewGuid(), NameRu = "C#", NameTj = "C#" };
        var java = new Skill { Id = Guid.NewGuid(), NameRu = "Java", NameTj = "Java" };

        var result = _sut.Calculate(
            candidateSkills: [java],
            requiredSkills: [csharp]);

        result.ScorePercent.Should().Be(0);
        result.MatchedSkills.Should().BeEmpty();
        result.MissingSkills.Should().ContainSingle(s => s.Id == csharp.Id);
    }

    [Fact]
    public void Calculate_PartialMatch_ReturnsCorrectPercent()
    {
        var csharp = new Skill { Id = Guid.NewGuid(), NameRu = "C#", NameTj = "C#" };
        var dotnet = new Skill { Id = Guid.NewGuid(), NameRu = ".NET", NameTj = ".NET" };
        var docker = new Skill { Id = Guid.NewGuid(), NameRu = "Docker", NameTj = "Docker" };

        var result = _sut.Calculate(
            candidateSkills: [csharp, dotnet],
            requiredSkills: [csharp, dotnet, docker]);

        result.ScorePercent.Should().Be(67); // 2 из 3, округление
        result.MatchedSkills.Should().HaveCount(2);
        result.MissingSkills.Should().ContainSingle(s => s.Id == docker.Id);
    }

    [Fact]
    public void Calculate_NoRequiredSkills_Returns100Percent()
    {
        var result = _sut.Calculate(candidateSkills: [], requiredSkills: []);

        result.ScorePercent.Should().Be(100);
    }
}