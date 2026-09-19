import '../../domain/entities/auth_result.dart';

class AuthResponseModel {
  final String userId;
  final String role;
  final String accessToken;
  final String refreshToken;

  AuthResponseModel({
    required this.userId,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AuthResponseModel(
      userId: data['userId'],
      role: data['role'],
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
  }

  AuthResult toEntity() => AuthResult(
        userId: userId,
        role: role,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}