import '../entities/auth_result.dart';
import '../repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<AuthResult> call(String email, String password) {
    return _repository.login(email, password);
  }
}