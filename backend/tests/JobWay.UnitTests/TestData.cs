using JobWay.Domain.Entities;
using JobWay.Domain.Enums;

namespace JobWay.UnitTests;

public static class TestData
{
    public static Skill MakeSkill(string name = "C#") => new()
    {
        Id = Guid.NewGuid(),
        NameRu = name,
        NameTj = name
    };

    public static CompanyProfile MakeCompany(
        VerificationStatus verification = VerificationStatus.Verified,
        CompanyTier tier = CompanyTier.Free,
        DateTime? tierExpiresAt = null) => new()
    {
        Id = Guid.NewGuid(),
        UserId = Guid.NewGuid(),
        CompanyName = "TestCo",
        VerificationStatus = verification,
        Tier = tier,
        TierExpiresAt = tierExpiresAt
    };

    // Вакансия, которая проходит VacancyRules.Validate
    public static Vacancy MakeVacancy(CompanyProfile company, VacancyStatus status = VacancyStatus.Draft) => new()
    {
        Id = Guid.NewGuid(),
        CompanyProfileId = company.Id,
        CompanyProfile = company,
        Title = "Backend developer",
        Description = "Разработка и поддержка backend-сервисов компании",
        Responsibilities = "Писать код\nПроводить ревью",
        Requirements = "Опыт от года\nЗнание C#",
        Location = "Душанбе",
        SalaryFrom = 3000,
        SalaryTo = 5000,
        Status = status,
        RequiredSkills = [MakeSkill()]
    };
}