using System.ComponentModel.DataAnnotations;

namespace JobWay.Application.DTOs.Skill.Request;

public class CreateSkillRequest
{
    [Required]
    public string NameRu { get; set; } = string.Empty;

    [Required]
    public string NameTj { get; set; } = string.Empty;

    public string? Category { get; set; }
}