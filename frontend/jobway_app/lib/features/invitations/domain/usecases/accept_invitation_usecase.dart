import '../repository/invitations_repository.dart';

class AcceptInvitationUseCase {
  final InvitationsRepository _repository;

  AcceptInvitationUseCase(this._repository);

  Future<void> call(String id) => _repository.accept(id);
}