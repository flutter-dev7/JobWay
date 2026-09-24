import 'dart:io';
import '../entities/candidate_profile.dart';
import '../repository/candidate_profile_repository.dart';

class UploadResumeUseCase {
  final CandidateProfileRepository _repository;
  UploadResumeUseCase(this._repository);
  Future<CandidateProfile> call(File file) => _repository.uploadResume(file);
}