import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/services/push_notification_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repository/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(dioClientProvider).dio),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider), ref.read(tokenStorageProvider)),
);

final loginUseCaseProvider = Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));
final registerUseCaseProvider = Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<AuthResult?>>(
  (ref) => AuthController(
    ref.read(loginUseCaseProvider),
    ref.read(registerUseCaseProvider),
    ref.read(pushNotificationServiceProvider),
  ),
);

class AuthController extends StateNotifier<AsyncValue<AuthResult?>> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final PushNotificationService _pushNotificationService;

  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._pushNotificationService,
  ) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _loginUseCase(email, password);

      await _pushNotificationService.registerToken();

      return result;
    });
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

    state = await AsyncValue.guard(() async {
      final result = await _registerUseCase(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        role: role,
        name: name,
        phoneNumber: phoneNumber,
      );

      await _pushNotificationService.registerToken();

      return result;
    });
  }
}