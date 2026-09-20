import '../entities/candidate_profile.dart';
import '../repository/candidate_profile_repository.dart';

class GetCandidateProfileUseCase {
  final CandidateProfileRepository _repository;

  GetCandidateProfileUseCase(this._repository);

  Future<CandidateProfile> call() => _repository.getMyProfile();
}