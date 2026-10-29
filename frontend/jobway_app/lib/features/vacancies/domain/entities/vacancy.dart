import '../../../skills/domain/entities/skill.dart';

class Vacancy {
  final String id;
  final String companyProfileId;
  final String companyUserId;
  final String companyName;
  final String title;
  final String description;
  final String? responsibilities;
  final String? requirements;
  final String employmentType;
  final String experienceLevel;
  final String paymentType;
  final String currency;
  final String? location;
  final String? companyLogoUrl;
  final double? salaryFrom;
  final double? salaryTo;
  final String status;
  final List<Skill> skills;
  final DateTime createdAt;
  final DateTime? featuredUntil;
  final DateTime? expiresAt;
  final String? companyPhone;
  final String? companyTelegram;

  const Vacancy({
    required this.id,
    required this.companyProfileId,
    required this.companyUserId,
    required this.companyName,
    required this.title,
    required this.description,
    this.responsibilities,
    this.requirements,
    required this.employmentType,
    required this.experienceLevel,
    required this.paymentType,
    required this.currency,
    this.location,
    this.companyLogoUrl,
    this.salaryFrom,
    this.salaryTo,
    required this.status,
    required this.skills,
    required this.createdAt,
    this.featuredUntil,
    this.expiresAt,
    this.companyPhone,
    this.companyTelegram,
  });

  bool get isFeatured =>
      status == 'Active' &&
      featuredUntil != null &&
      featuredUntil!.isAfter(DateTime.now());

  int? get daysLeft {
    if (status != 'Active' || expiresAt == null) return null;
    final minutes = expiresAt!.difference(DateTime.now()).inMinutes;
    if (minutes <= 0) return 0;
    return (minutes / 1440).ceil();
  }

  bool get canRenew => daysLeft != null && daysLeft! <= 7;

  bool get hasContacts =>
      (companyPhone != null && companyPhone!.isNotEmpty) ||
      (companyTelegram != null && companyTelegram!.isNotEmpty);
}
