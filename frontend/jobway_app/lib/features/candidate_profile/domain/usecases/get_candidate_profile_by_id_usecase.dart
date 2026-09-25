import '../entities/candidate_profile.dart';
import '../repository/candidate_profile_repository.dart';

class GetCandidateProfileByIdUseCase {
  final CandidateProfileRepository _repository;
  GetCandidateProfileByIdUseCase(this._repository);
  Future<CandidateProfile> call(String id) => _repository.getById(id);
}