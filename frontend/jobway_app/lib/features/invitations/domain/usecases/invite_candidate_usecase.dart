import '../repository/invitations_repository.dart';

class InviteCandidateUseCase {
  final InvitationsRepository _repository;

  InviteCandidateUseCase(this._repository);

  Future<void> call({
    required String vacancyId,
    required String candidateProfileId,
    String? message,
  }) => _repository.invite(
    vacancyId: vacancyId,
    candidateProfileId: candidateProfileId,
    message: message,
  );
}