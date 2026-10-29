import '../repository/invitations_repository.dart';

class DeclineInvitationUseCase {
  final InvitationsRepository _repository;

  DeclineInvitationUseCase(this._repository);

  Future<void> call(String id) => _repository.decline(id);
}