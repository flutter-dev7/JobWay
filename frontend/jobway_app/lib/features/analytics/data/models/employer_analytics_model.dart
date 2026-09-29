import '../../../../core/network/api_response.dart';
import '../../domain/entities/employer_analytics.dart';

class StatusFunnelItemModel {
  final String status;
  final int count;

  StatusFunnelItemModel({required this.status, required this.count});

  factory StatusFunnelItemModel.fromJson(Map<String, dynamic> json) =>
      StatusFunnelItemModel(status: json['status'], count: json['count']);

  StatusFunnelItem toEntity() => StatusFunnelItem(status: status, count: count);
}

class TopSkillItemModel {
  final String skillId;
  final String nameRu;
  final String nameTj;
  final int count;

  TopSkillItemModel({
    required this.skillId,
    required this.nameRu,
    required this.nameTj,
    required this.count,
  });

  factory TopSkillItemModel.fromJson(Map<String, dynamic> json) => TopSkillItemModel(
        skillId: json['skillId'],
        nameRu: json['nameRu'],
        nameTj: json['nameTj'],
        count: json['count'],
      );

  TopSkillItem toEntity() =>
      TopSkillItem(skillId: skillId, nameRu: nameRu, nameTj: nameTj, count: count);
}

class VacancyAnalyticsItemModel {
  final String vacancyId;
  final String title;
  final String status;
  final int applicationsCount;
  final double averageMatchScore;

  VacancyAnalyticsItemModel({
    required this.vacancyId,
    required this.title,
    required this.status,
    required this.applicationsCount,
    required this.averageMatchScore,
  });

  factory VacancyAnalyticsItemModel.fromJson(Map<String, dynamic> json) => VacancyAnalyticsItemModel(
        vacancyId: json['vacancyId'],
        title: json['title'],
        status: json['status'],
        applicationsCount: json['applicationsCount'],
        averageMatchScore: (json['averageMatchScore'] as num).toDouble(),
      );

  VacancyAnalyticsItem toEntity() => VacancyAnalyticsItem(
        vacancyId: vacancyId,
        title: title,
        status: status,
        applicationsCount: applicationsCount,
        averageMatchScore: averageMatchScore,
      );
}

class EmployerAnalyticsModel {
  final int totalVacancies;
  final int activeVacancies;
  final int totalApplications;
  final double averageMatchScore;
  final List<StatusFunnelItemModel> statusFunnel;
  final List<TopSkillItemModel> topSkills;
  final List<VacancyAnalyticsItemModel> vacancies;

  EmployerAnalyticsModel({
    required this.totalVacancies,
    required this.activeVacancies,
    required this.totalApplications,
    required this.averageMatchScore,
    required this.statusFunnel,
    required this.topSkills,
    required this.vacancies,
  });

  factory EmployerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return EmployerAnalyticsModel(
      totalVacancies: data['totalVacancies'],
      activeVacancies: data['activeVacancies'],
      totalApplications: data['totalApplications'],
      averageMatchScore: (data['averageMatchScore'] as num).toDouble(),
      statusFunnel: (data['statusFunnel'] as List)
          .map((e) => StatusFunnelItemModel.fromJson(e))
          .toList(),
      topSkills:
          (data['topSkills'] as List).map((e) => TopSkillItemModel.fromJson(e)).toList(),
      vacancies: (data['vacancies'] as List)
          .map((e) => VacancyAnalyticsItemModel.fromJson(e))
          .toList(),
    );
  }

  EmployerAnalytics toEntity() => EmployerAnalytics(
        totalVacancies: totalVacancies,
        activeVacancies: activeVacancies,
        totalApplications: totalApplications,
        averageMatchScore: averageMatchScore,
        statusFunnel: statusFunnel.map((e) => e.toEntity()).toList(),
        topSkills: topSkills.map((e) => e.toEntity()).toList(),
        vacancies: vacancies.map((e) => e.toEntity()).toList(),
      );
}