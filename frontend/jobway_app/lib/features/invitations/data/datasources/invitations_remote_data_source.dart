import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/invitation_model.dart';

class InvitationsRemoteDataSource {
  final Dio _dio;

  InvitationsRemoteDataSource(this._dio);

  Future<void> invite({
    required String vacancyId,
    required String candidateProfileId,
    String? message,
  }) async {
    await _dio.post(
      ApiConstants.invitations,
      data: {
        'vacancyId': vacancyId,
        'candidateProfileId': candidateProfileId,
        'message': message,
      },
    );
  }

  // Ожидающих ответа приглашений немного, поэтому берём одну страницу целиком
  Future<List<InvitationModel>> getPending() async {
    final response = await _dio.get(
      ApiConstants.myInvitations,
      queryParameters: {'status': 'Pending', 'pageNumber': 1, 'pageSize': 50},
    );
    final data = ApiResponse.unwrap(response.data);
    return (data['items'] as List)
        .map((i) => InvitationModel.fromJson(i))
        .toList();
  }

  Future<void> accept(String id) async {
    await _dio.post(ApiConstants.acceptInvitation(id));
  }

  Future<void> decline(String id) async {
    await _dio.post(ApiConstants.declineInvitation(id));
  }

  Future<Map<String, String>> getBlocked(String candidateProfileId) async {
    final response = await _dio.get(
      ApiConstants.blockedInviteVacancies(candidateProfileId),
    );
    final list = ApiResponse.unwrap(response.data) as List;
    return {
      for (final item in list) item['vacancyId'] as String: item['reason'] as String,
    };
  }
}