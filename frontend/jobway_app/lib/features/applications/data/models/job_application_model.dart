import '../../../../core/network/api_response.dart';
import '../../../skills/data/models/skill_model.dart';
import '../../domain/entities/job_application.dart';

class JobApplicationModel {
  final String id;
  final String vacancyId;
  final String vacancyTitle;
  final String companyName;
  final String candidateProfileId;
  final String candidateFullName;
  final String status;
  final int matchScore;
  final List<SkillModel> matchedSkills;
  final List<SkillModel> missingSkills;
  final String? coverMessage;
  final String? companyLogoUrl;
  final String? candidatePhotoUrl;
  final DateTime createdAt;
  final bool hasReviewFromCurrentUser;
  final bool candidateAccountDeleted;

  JobApplicationModel({
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

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return JobApplicationModel(
      id: data['id'],
      vacancyId: data['vacancyId'],
      vacancyTitle: data['vacancyTitle'],
      companyName: data['companyName'],
      candidateProfileId: data['candidateProfileId'],
      candidateFullName: data['candidateFullName'],
      status: data['status'],
      matchScore: data['matchScore'],
      matchedSkills: (data['matchedSkills'] as List)
          .map((s) => SkillModel.fromJson(s))
          .toList(),
      missingSkills: (data['missingSkills'] as List)
          .map((s) => SkillModel.fromJson(s))
          .toList(),
      coverMessage: data['coverMessage'],
      companyLogoUrl: data['companyLogoUrl'],
      candidatePhotoUrl: data['candidatePhotoUrl'],
      createdAt: DateTime.parse(data['createdAt']),
      hasReviewFromCurrentUser: data['hasReviewFromCurrentUser'] ?? false,
      candidateAccountDeleted: data['candidateAccountDeleted'] ?? false,
    );
  }

  JobApplication toEntity() => JobApplication(
    id: id,
    vacancyId: vacancyId,
    vacancyTitle: vacancyTitle,
    companyName: companyName,
    candidateProfileId: candidateProfileId,
    candidateFullName: candidateFullName,
    status: status,
    matchScore: matchScore,
    matchedSkills: matchedSkills.map((s) => s.toEntity()).toList(),
    missingSkills: missingSkills.map((s) => s.toEntity()).toList(),
    coverMessage: coverMessage,
    companyLogoUrl: companyLogoUrl,
    candidatePhotoUrl: candidatePhotoUrl,
    createdAt: createdAt,
    hasReviewFromCurrentUser: hasReviewFromCurrentUser,
    candidateAccountDeleted: candidateAccountDeleted,
  );
}