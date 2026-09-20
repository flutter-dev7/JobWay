import '../../../skills/domain/entities/skill.dart';

class CandidateProfile {
  final String id;
  final String fullName;
  final DateTime? birthDate;
  final String? location;
  final String? bio;
  final String? resumeFileUrl;
  final String experienceLevel;
  final String desiredEmploymentType;
  final List<Skill> skills;

  const CandidateProfile({
    required this.id,
    required this.fullName,
    this.birthDate,
    this.location,
    this.bio,
    this.resumeFileUrl,
    required this.experienceLevel,
    required this.desiredEmploymentType,
    required this.skills,
  });
}