import '../../../skills/domain/entities/skill.dart';

class JobApplication {
  final String id;
  final String vacancyId;
  final String vacancyTitle;
  final String companyName;
  final String candidateProfileId;
  final String candidateFullName;
  final String status;
  final int matchScore;
  final List<Skill> matchedSkills;
  final List<Skill> missingSkills;
  final String? coverMessage;
  final String? companyLogoUrl;
  final String? candidatePhotoUrl;
  final DateTime createdAt;
  final bool hasReviewFromCurrentUser;
  final bool candidateAccountDeleted;

  const JobApplication({
    required this.id,
    required this.vacancyId,
    required this.vacancyTitle,
    required this.companyName,
    required this.candidateProfileId,
    required this.candidateFullName,
    required this.status,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    this.coverMessage,
    this.companyLogoUrl,
    this.candidatePhotoUrl,
    required this.createdAt,
    required this.hasReviewFromCurrentUser,
    this.candidateAccountDeleted = false,
  });
}