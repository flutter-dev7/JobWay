import '../repository/invitations_repository.dart';

class GetBlockedInviteVacanciesUseCase {
  final InvitationsRepository _repository;

  GetBlockedInviteVacanciesUseCase(this._repository);

  Future<Map<String, String>> call(String candidateProfileId) =>
      _repository.getBlocked(candidateProfileId);
}