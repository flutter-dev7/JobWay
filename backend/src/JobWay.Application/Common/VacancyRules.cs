namespace JobWay.Application.Common;

public static class VacancyRules
{
    public const int MinTitleLength = 3;
    public const int MinDescriptionLength = 20;
    public const int MaxDescriptionLength = 3000;
    public const int MinListLength = 10;
    public const int MaxListLength = 2000;
    public const int MaxSkills = 20;
    public const int LifetimeDays = 30;
    public const int ExpiryNoticeDays = 3;

    // Возвращает текст ошибки или null, если вакансия заполнена правильно
    public static string? Validate(
        string? title,
        string? description,
        string? responsibilities,
        string? requirements,
        string? location,
        decimal? salaryFrom,
        decimal? salaryTo,
        int skillCount)
    {
        if (string.IsNullOrWhiteSpace(title) || title.Trim().Length < MinTitleLength)
            return $"Введите название вакансии (минимум {MinTitleLength} символа)";

        if (string.IsNullOrWhiteSpace(description) || description.Trim().Length < MinDescriptionLength)
            return $"Добавьте описание вакансии (минимум {MinDescriptionLength} символов)";

        if (description.Trim().Length > MaxDescriptionLength)
            return $"Описание слишком длинное (максимум {MaxDescriptionLength} символов)";

        if (string.IsNullOrWhiteSpace(responsibilities) || responsibilities.Trim().Length < MinListLength)
            return "Опишите обязанности (каждый пункт с новой строки)";

        if (responsibilities.Trim().Length > MaxListLength)
            return $"Обязанности слишком длинные (максимум {MaxListLength} символов)";

        if (string.IsNullOrWhiteSpace(requirements) || requirements.Trim().Length < MinListLength)
            return "Опишите требования к кандидату (каждый пункт с новой строки)";

        if (requirements.Trim().Length > MaxListLength)
            return $"Требования слишком длинные (максимум {MaxListLength} символов)";

        if (string.IsNullOrWhiteSpace(location))
            return "Укажите локацию";

        if (salaryFrom is null && salaryTo is null)
            return "Укажите зарплату: «от» или «до»";

        if (salaryFrom is <= 0 || salaryTo is <= 0)
            return "Зарплата должна быть больше нуля";

        if (salaryFrom is not null && salaryTo is not null && salaryFrom > salaryTo)
            return "Зарплата «от» не может быть больше «до»";

        if (skillCount == 0)
            return "Выберите хотя бы один навык";

        if (skillCount > MaxSkills)
            return $"Можно выбрать не больше {MaxSkills} навыков";

        return null;
    }
}