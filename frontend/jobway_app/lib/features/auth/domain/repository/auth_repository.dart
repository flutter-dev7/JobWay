import '../entities/auth_result.dart';

abstract class AuthRepository {
  Future<void> sendRegistrationCode(String email);
  Future<void> verifyRegistrationCode(String email, String code);

  Future<AuthResult> login(String email, String password);

  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    String? phoneNumber,
  });

  Future<void> forgotPassword(String email);
  Future<void> verifyResetCode(String email, String code);
  Future<void> resetPassword(String email, String newPassword, String confirmPassword);

    Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });

  Future<void> logout();
}