import '../entities/candidate_profile.dart';
import '../repository/candidate_profile_repository.dart';

class UpdateCandidateProfileUseCase {
  final CandidateProfileRepository _repository;

  UpdateCandidateProfileUseCase(this._repository);

  Future<CandidateProfile> call({
    required String fullName,
    DateTime? birthDate,
    String? location,
    String? bio,
    String? resumeFileUrl,
    required String experienceLevel,
    required String desiredEmploymentType,
    required List<String> skillIds,
  }) =>
      _repository.updateMyProfile(
        fullName: fullName,
        birthDate: birthDate,
        location: location,
        bio: bio,
        resumeFileUrl: resumeFileUrl,
        experienceLevel: experienceLevel,
        desiredEmploymentType: desiredEmploymentType,
        skillIds: skillIds,
      );
}