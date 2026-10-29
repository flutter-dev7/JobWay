import '../../domain/entities/invitation.dart';
import '../../domain/repository/invitations_repository.dart';
import '../datasources/invitations_remote_data_source.dart';

class InvitationsRepositoryImpl implements InvitationsRepository {
  final InvitationsRemoteDataSource _remoteDataSource;

  InvitationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> invite({
    required String vacancyId,
    required String candidateProfileId,
    String? message,
  }) => _remoteDataSource.invite(
    vacancyId: vacancyId,
    candidateProfileId: candidateProfileId,
    message: message,
  );

  @override
  Future<Map<String, String>> getBlocked(String candidateProfileId) =>
      _remoteDataSource.getBlocked(candidateProfileId);

  @override
  Future<List<Invitation>> getPending() async {
    final models = await _remoteDataSource.getPending();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> accept(String id) => _remoteDataSource.accept(id);

  @override
  Future<void> decline(String id) => _remoteDataSource.decline(id);
}
