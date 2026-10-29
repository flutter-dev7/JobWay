import '../entities/invitation.dart';

abstract class InvitationsRepository {
  Future<void> invite({
    required String vacancyId,
    required String candidateProfileId,
    String? message,
  });
  Future<Map<String, String>> getBlocked(String candidateProfileId);
  Future<List<Invitation>> getPending();
  Future<void> accept(String id);
  Future<void> decline(String id);
}