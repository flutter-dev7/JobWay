import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<AuthResult> login(String email, String password) async {
    final model = await _remoteDataSource.login(email, password);
    await _tokenStorage.saveTokens(accessToken: model.accessToken, refreshToken: model.refreshToken);
    await _tokenStorage.saveRole(model.role);
    return model.toEntity();
  }

  @override
  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    String? phoneNumber,
  }) async {
    final model = await _remoteDataSource.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
      name: name,
      phoneNumber: phoneNumber,
    );
    await _tokenStorage.saveTokens(accessToken: model.accessToken, refreshToken: model.refreshToken);
    await _tokenStorage.saveRole(model.role);
    return model.toEntity();
  }

  @override
  Future<void> forgotPassword(String email) => _remoteDataSource.forgotPassword(email);

  @override
  Future<void> verifyResetCode(String email, String code) => _remoteDataSource.verifyResetCode(email, code);

  @override
  Future<void> resetPassword(String email, String newPassword, String confirmPassword) =>
      _remoteDataSource.resetPassword(email, newPassword, confirmPassword);

  @override
  Future<void> logout() => _tokenStorage.clear();
}