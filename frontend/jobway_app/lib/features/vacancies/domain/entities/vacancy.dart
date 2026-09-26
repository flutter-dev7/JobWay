import '../../../skills/domain/entities/skill.dart';

class Vacancy {
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
  final List<Skill> skills;
  final DateTime createdAt;

  const Vacancy({
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
}
