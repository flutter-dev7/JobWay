import '../../../skills/domain/entities/skill.dart';

class CandidateProfile {
  final String id;
  final String userId;
  final String fullName;
  final DateTime? birthDate;
  final String? location;
  final String? bio;
  final String? resumeFileUrl;
  final String? photoUrl;
  final String experienceLevel;
  final String desiredEmploymentType;
  final List<Skill> skills;

  const CandidateProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.birthDate,
    this.location,
    this.bio,
    this.resumeFileUrl,
    this.photoUrl,
    required this.experienceLevel,
    required this.desiredEmploymentType,
    required this.skills,
  });
}