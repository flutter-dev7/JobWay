// features/vacancies/data/models/vacancy_model.dart
import '../../../skills/data/models/skill_model.dart';
import '../../domain/entities/vacancy.dart';

class VacancyModel {
  final String id;
  final String companyProfileId;
  final String companyUserId;
  final String companyName;
  final String title;
  final String description;
  final String employmentType;
  final String experienceLevel;
  final String? location;
  final String? companyLogoUrl;
  final double? salaryFrom;
  final double? salaryTo;
  final String status;
  final List<SkillModel> skills;
  final DateTime createdAt;

  VacancyModel({
    required this.id,
    required this.companyProfileId,
    required this.companyUserId,
    required this.companyName,
    required this.title,
    required this.description,
    required this.employmentType,
    required this.experienceLevel,
    this.location,
    this.companyLogoUrl,
    this.salaryFrom,
    this.salaryTo,
    required this.status,
    required this.skills,
    required this.createdAt,
  });

  factory VacancyModel.fromJson(Map<String, dynamic> json) => VacancyModel(
    id: json['id'],
    companyProfileId: json['companyProfileId'],
    companyUserId: json['companyUserId'],
    companyName: json['companyName'],
    title: json['title'],
    description: json['description'],
    employmentType: json['employmentType'],
    experienceLevel: json['experienceLevel'],
    location: json['location'],
    companyLogoUrl: json['companyLogoUrl'],
    salaryFrom: (json['salaryFrom'] as num?)?.toDouble(),
    salaryTo: (json['salaryTo'] as num?)?.toDouble(),
    status: json['status'],
    skills: (json['skills'] as List)
        .map((s) => SkillModel.fromJson(s))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );

  Vacancy toEntity() => Vacancy(
    id: id,
    companyProfileId: companyProfileId,
    companyUserId: companyUserId,
    companyName: companyName,
    title: title,
    description: description,
    employmentType: employmentType,
    experienceLevel: experienceLevel,
    location: location,
    companyLogoUrl: companyLogoUrl,
    salaryFrom: salaryFrom,
    salaryTo: salaryTo,
    status: status,
    skills: skills.map((s) => s.toEntity()).toList(),
    createdAt: createdAt,
  );
}
