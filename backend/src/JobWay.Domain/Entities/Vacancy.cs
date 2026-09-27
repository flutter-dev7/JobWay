using JobWay.Domain.Common;
using JobWay.Domain.Enums;

namespace JobWay.Domain.Entities;

public class Vacancy : BaseEntity
{
    public Guid CompanyProfileId { get; set; }
    public CompanyProfile CompanyProfile { get; set; } = null!;

    public string Title { get; set; } = null!;
    public string Description { get; set; } = null!;
    public EmploymentType EmploymentType { get; set; }
    public ExperienceLevel ExperienceLevel { get; set; }
    public string? Location { get; set; }
    public decimal? SalaryFrom { get; set; }
    public decimal? SalaryTo { get; set; }
    public VacancyStatus Status { get; set; } = VacancyStatus.Draft;
    public PaymentType PaymentType { get; set; } = PaymentType.Monthly;
    public Currency Currency { get; set; } = Currency.TJS;

    public List<Skill> RequiredSkills { get; set; } = [];
    public List<JobApplication> Applications { get; set; } = [];
}