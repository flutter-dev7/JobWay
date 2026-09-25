import 'dart:io';

import '../../domain/entities/candidate_profile.dart';
import '../../domain/repository/candidate_profile_repository.dart';
import '../datasources/candidate_profile_remote_data_source.dart';

class CandidateProfileRepositoryImpl implements CandidateProfileRepository {
  final CandidateProfileRemoteDataSource _remoteDataSource;

  CandidateProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<CandidateProfile> getMyProfile() async {
    final model = await _remoteDataSource.getMyProfile();
    return model.toEntity();
  }

  @override
  Future<CandidateProfile> updateMyProfile({
    required String fullName,
    DateTime? birthDate,
    String? location,
    String? bio,
    String? resumeFileUrl,
    required String experienceLevel,
    required String desiredEmploymentType,
    required List<String> skillIds,
  }) async {
    final model = await _remoteDataSource.updateMyProfile(
      fullName: fullName,
      birthDate: birthDate,
      location: location,
      bio: bio,
      resumeFileUrl: resumeFileUrl,
      experienceLevel: experienceLevel,
      desiredEmploymentType: desiredEmploymentType,
      skillIds: skillIds,
    );
    return model.toEntity();
  }

  @override
  Future<CandidateProfile> uploadResume(File file) async {
    final model = await _remoteDataSource.uploadResume(file);
    return model.toEntity();
  }

  @override
  Future<CandidateProfile> uploadPhoto(File file) async {
    final model = await _remoteDataSource.uploadPhoto(file);
    return model.toEntity();
  }

  @override
  Future<CandidateProfile> getById(String id) async {
    final model = await _remoteDataSource.getById(id);
    return model.toEntity();
  }
}
