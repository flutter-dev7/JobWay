class VacancyFormRules {
  static const minTitleLength = 3;
  static const minDescriptionLength = 20;
  static const maxDescriptionLength = 3000;
  static const minListLength = 10;
  static const maxListLength = 2000;
  static const maxSkills = 20;

  static double? parseMoney(String text) {
    final cleaned = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    return cleaned.isEmpty ? null : double.tryParse(cleaned);
  }

  static String? validateMain({required String title, required String description}) {
    if (title.trim().length < minTitleLength) {
      return 'Введите название вакансии (минимум $minTitleLength символа)';
    }
    if (description.trim().length < minDescriptionLength) {
      return 'Добавьте описание вакансии (минимум $minDescriptionLength символов)';
    }
    return null;
  }

  static String? validateDuties({
    required String responsibilities,
    required String requirements,
  }) {
    if (responsibilities.trim().length < minListLength) {
      return 'Опишите обязанности (каждый пункт с новой строки)';
    }
    if (requirements.trim().length < minListLength) {
      return 'Опишите требования к кандидату (каждый пункт с новой строки)';
    }
    return null;
  }

  static String? validateConditions({
    required String location,
    required String salaryFrom,
    required String salaryTo,
  }) {
    if (location.trim().isEmpty) return 'Укажите локацию';

    final from = parseMoney(salaryFrom);
    final to = parseMoney(salaryTo);

    if ((salaryFrom.trim().isNotEmpty && from == null) ||
        (salaryTo.trim().isNotEmpty && to == null)) {
      return 'Введите зарплату числом';
    }
    if (from == null && to == null) return 'Укажите зарплату: «от» или «до»';
    if ((from != null && from <= 0) || (to != null && to <= 0)) {
      return 'Зарплата должна быть больше нуля';
    }
    if (from != null && to != null && from > to) {
      return 'Зарплата «от» не может быть больше «до»';
    }
    return null;
  }

  static String? validateSkills(int count) {
    if (count == 0) return 'Выберите хотя бы один навык';
    if (count > maxSkills) return 'Можно выбрать не больше $maxSkills навыков';
    return null;
  }

  static String? validateAll({
    required String title,
    required String description,
    required String responsibilities,
    required String requirements,
    required String location,
    required String salaryFrom,
    required String salaryTo,
    required int skillCount,
  }) {
    return validateMain(title: title, description: description) ??
        validateDuties(responsibilities: responsibilities, requirements: requirements) ??
        validateConditions(location: location, salaryFrom: salaryFrom, salaryTo: salaryTo) ??
        validateSkills(skillCount);
  }
}