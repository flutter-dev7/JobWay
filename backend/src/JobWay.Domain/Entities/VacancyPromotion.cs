using JobWay.Domain.Common;

namespace JobWay.Domain.Entities;

public class VacancyPromotion : BaseEntity
{
    public Guid VacancyId { get; set; }
    public Vacancy Vacancy { get; set; } = null!;

    public int Days { get; set; }
}