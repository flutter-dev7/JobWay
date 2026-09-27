using System.ComponentModel.DataAnnotations;
using JobWay.Domain.Enums;

namespace JobWay.Application.DTOs.Vacancy.Request;

public class UpdateVacancyRequest
{
    [Required]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string Description { get; set; } = string.Empty;

    public EmploymentType EmploymentType { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public PaymentType PaymentType { get; set; } = PaymentType.Monthly;
    public Currency Currency { get; set; } = Currency.TJS;
    public string? Location { get; set; }
    public decimal? SalaryFrom { get; set; }
    public decimal? SalaryTo { get; set; }
    public List<Guid> SkillIds { get; set; } = [];
}