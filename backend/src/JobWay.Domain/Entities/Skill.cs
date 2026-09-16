using JobWay.Domain.Common;

namespace JobWay.Domain.Entities;

public class Skill : BaseEntity
{
    public string NameRu { get; set; } = null!;
    public string NameTj { get; set; } = null!;
    public string? Category { get; set; } // например "Языки программирования", "Софт-скиллы"

    public List<CandidateProfile> CandidateProfiles { get; set; } = [];
    public List<Vacancy> Vacancies { get; set; } = [];
}