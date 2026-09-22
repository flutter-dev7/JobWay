using JobWay.Domain.Common;

namespace JobWay.Domain.Entities;

public class SavedVacancy : BaseEntity
{
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;

    public Guid VacancyId { get; set; }
    public Vacancy Vacancy { get; set; } = null!;
}