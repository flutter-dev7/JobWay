import '../entities/auth_result.dart';
import '../repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<AuthResult> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    String? phoneNumber,
  }) {
    return _repository.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
      name: name,
      phoneNumber: phoneNumber,
    );
  }
}