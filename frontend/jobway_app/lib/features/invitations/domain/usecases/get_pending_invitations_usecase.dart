import '../entities/invitation.dart';
import '../repository/invitations_repository.dart';

class GetPendingInvitationsUseCase {
  final InvitationsRepository _repository;

  GetPendingInvitationsUseCase(this._repository);

  Future<List<Invitation>> call() => _repository.getPending();
}