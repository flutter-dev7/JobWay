// features/auth/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioClientProvider = Provider((ref) => DioClient(ref.read(tokenStorageProvider)));

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(dioClientProvider).dio),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider), ref.read(tokenStorageProvider)),
);

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthResult?>>(
  (ref) => AuthController(ref.read(loginUseCaseProvider), ref.read(registerUseCaseProvider)),
);

class AuthController extends StateNotifier<AsyncValue<AuthResult?>> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthController(this._loginUseCase, this._registerUseCase) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loginUseCase(email, password));
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    required String name,
    String? phoneNumber,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _registerUseCase(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
          role: role,
          name: name,
          phoneNumber: phoneNumber,
        ));
  }
}