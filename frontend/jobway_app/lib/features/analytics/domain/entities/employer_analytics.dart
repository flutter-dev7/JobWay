class StatusFunnelItem {
  final String status;
  final int count;

  const StatusFunnelItem({required this.status, required this.count});
}

class TopSkillItem {
  final String skillId;
  final String nameRu;
  final String nameTj;
  final int count;

  const TopSkillItem({
    required this.skillId,
    required this.nameRu,
    required this.nameTj,
    required this.count,
  });
}

class VacancyAnalyticsItem {
  final String vacancyId;
  final String title;
  final String status;
  final int applicationsCount;
  final double averageMatchScore;

  const VacancyAnalyticsItem({
    required this.vacancyId,
    required this.title,
    required this.status,
    required this.applicationsCount,
    required this.averageMatchScore,
  });
}

class EmployerAnalytics {
  final int totalVacancies;
  final int activeVacancies;
  final int totalApplications;
  final double averageMatchScore;
  final List<StatusFunnelItem> statusFunnel;
  final List<TopSkillItem> topSkills;
  final List<VacancyAnalyticsItem> vacancies;

  const EmployerAnalytics({
    required this.totalVacancies,
    required this.activeVacancies,
    required this.totalApplications,
    required this.averageMatchScore,
    required this.statusFunnel,
    required this.topSkills,
    required this.vacancies,
  });
}