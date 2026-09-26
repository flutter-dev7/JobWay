import '../../../../core/network/api_response.dart';
import '../../../skills/data/models/skill_model.dart';
import '../../domain/entities/candidate_profile.dart';

class CandidateProfileModel {
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
  final List<SkillModel> skills;

  CandidateProfileModel({
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

  factory CandidateProfileModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return CandidateProfileModel(
      id: data['id'],
      userId: data['userId'],
      fullName: data['fullName'],
      birthDate: data['birthDate'] != null ? DateTime.tryParse(data['birthDate']) : null,
      location: data['location'],
      bio: data['bio'],
      resumeFileUrl: data['resumeFileUrl'],
      photoUrl: data['photoUrl'],
      experienceLevel: data['experienceLevel'],
      desiredEmploymentType: data['desiredEmploymentType'],
      skills: (data['skills'] as List).map((s) => SkillModel.fromJson(s)).toList(),
    );
  }

  CandidateProfile toEntity() => CandidateProfile(
        id: id,
        userId: userId,
        fullName: fullName,
        birthDate: birthDate,
        location: location,
        bio: bio,
        resumeFileUrl: resumeFileUrl,
        photoUrl: photoUrl,
        experienceLevel: experienceLevel,
        desiredEmploymentType: desiredEmploymentType,
        skills: skills.map((s) => s.toEntity()).toList(),
      );
}