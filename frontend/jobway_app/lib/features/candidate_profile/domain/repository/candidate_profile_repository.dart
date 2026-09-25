import 'dart:io';

import '../entities/candidate_profile.dart';

abstract class CandidateProfileRepository {
  Future<CandidateProfile> getMyProfile();

  Future<CandidateProfile> updateMyProfile({
    required String fullName,
    DateTime? birthDate,
    String? location,
    String? bio,
    String? resumeFileUrl,
    required String experienceLevel,
    required String desiredEmploymentType,
    required List<String> skillIds,
  });

  Future<CandidateProfile> uploadResume(File file);

  Future<CandidateProfile> uploadPhoto(File file);

  Future<CandidateProfile> getById(String id);
}
