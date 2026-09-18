using JobWay.Application.DTOs.Skill.Response;

namespace JobWay.Application.DTOs.JobApplication.Response;

public class MatchResult
{
    public int ScorePercent { get; set; }
    public List<SkillResponse> MatchedSkills { get; set; } = [];
    public List<SkillResponse> MissingSkills { get; set; } = [];
}