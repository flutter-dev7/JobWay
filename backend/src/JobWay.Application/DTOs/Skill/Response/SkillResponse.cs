namespace JobWay.Application.DTOs.Skill.Response;

public class SkillResponse
{
    public Guid Id { get; set; }
    public string NameRu { get; set; } = null!;
    public string NameTj { get; set; } = null!;
    public string? Category { get; set; }
}