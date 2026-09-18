using JobWay.Application.DTOs.JobApplication.Response;
using JobWay.Application.DTOs.Skill.Response;
using JobWay.Application.Interfaces.Services;
using JobWay.Domain.Entities;

namespace JobWay.Application.Services;

public class MatchingService : IMatchingService
{
    public MatchResult Calculate(List<Skill> candidateSkills, List<Skill> requiredSkills)
    {
        var candidateSkillIds = candidateSkills.Select(s => s.Id).ToHashSet();

        var matched = requiredSkills.Where(s => candidateSkillIds.Contains(s.Id)).ToList();
        var missing = requiredSkills.Where(s => !candidateSkillIds.Contains(s.Id)).ToList();

        var scorePercent = requiredSkills.Count == 0
            ? 100
            : (int)Math.Round(matched.Count * 100.0 / requiredSkills.Count);

        return new MatchResult
        {
            ScorePercent = scorePercent,
            MatchedSkills = matched.Select(MapSkill).ToList(),
            MissingSkills = missing.Select(MapSkill).ToList()
        };
    }

    private static SkillResponse MapSkill(Skill skill) => new()
    {
        Id = skill.Id,
        NameRu = skill.NameRu,
        NameTj = skill.NameTj,
        Category = skill.Category
    };
}