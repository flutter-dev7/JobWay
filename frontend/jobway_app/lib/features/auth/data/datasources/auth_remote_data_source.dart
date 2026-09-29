import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<AuthResponseModel> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    String? phoneNumber,
  }) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': role,
        'name': name,
        'phoneNumber': phoneNumber,
      },
    );
    return AuthResponseModel.fromJson(response.data);
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
  }

  Future<void> verifyResetCode(String email, String code) async {
    await _dio.post(
      ApiConstants.verifyResetCode,
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resetPassword(
    String email,
    String newPassword,
    String confirmPassword,
  ) async {
    await _dio.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _dio.post(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  Future<void> sendRegistrationCode(String email) async {
    await _dio.post(ApiConstants.sendRegistrationCode, data: {'email': email});
  }

  Future<void> verifyRegistrationCode(String email, String code) async {
    await _dio.post(
      ApiConstants.verifyRegistrationCode,
      data: {'email': email, 'code': code},
    );
  }
}
