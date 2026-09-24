import 'dart:io';
import '../entities/candidate_profile.dart';
import '../repository/candidate_profile_repository.dart';

class UploadCandidatePhotoUseCase {
  final CandidateProfileRepository _repository;
  UploadCandidatePhotoUseCase(this._repository);
  Future<CandidateProfile> call(File file) => _repository.uploadPhoto(file);
}