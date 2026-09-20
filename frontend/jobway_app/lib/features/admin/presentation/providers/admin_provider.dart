// features/admin/presentation/providers/admin_provider.dart — заменить целиком
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/admin_remote_data_source.dart';
import '../../data/repository/admin_repository_impl.dart';
import '../../domain/entities/company_moderation.dart';
import '../../domain/entities/user_moderation.dart';
import '../../domain/repository/admin_repository.dart';
import '../../domain/usecases/block_user_usecase.dart';
import '../../domain/usecases/get_companies_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/reject_company_usecase.dart';
import '../../domain/usecases/unblock_user_usecase.dart';
import '../../domain/usecases/verify_company_usecase.dart';

final adminRemoteDataSourceProvider = Provider(
  (ref) => AdminRemoteDataSource(ref.read(dioClientProvider).dio),
);

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepositoryImpl(ref.read(adminRemoteDataSourceProvider)),
);

final getCompaniesUseCaseProvider = Provider((ref) => GetCompaniesUseCase(ref.read(adminRepositoryProvider)));
final verifyCompanyUseCaseProvider = Provider((ref) => VerifyCompanyUseCase(ref.read(adminRepositoryProvider)));
final rejectCompanyUseCaseProvider = Provider((ref) => RejectCompanyUseCase(ref.read(adminRepositoryProvider)));

final getUsersUseCaseProvider = Provider((ref) => GetUsersUseCase(ref.read(adminRepositoryProvider)));
final blockUserUseCaseProvider = Provider((ref) => BlockUserUseCase(ref.read(adminRepositoryProvider)));
final unblockUserUseCaseProvider = Provider((ref) => UnblockUserUseCase(ref.read(adminRepositoryProvider)));

final adminCompaniesProvider =
    FutureProvider.autoDispose<List<CompanyModeration>>((ref) => ref.read(getCompaniesUseCaseProvider)());

// --- Юзеры: StateNotifier, чтобы менять статус на месте без пересортировки ---

class AdminUsersState {
  final List<UserModeration> users;
  final bool isLoading;
  final String? error;
  final String? updatingId;

  const AdminUsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.updatingId,
  });

  AdminUsersState copyWith({
    List<UserModeration>? users,
    bool? isLoading,
    String? error,
    String? updatingId,
    bool clearError = false,
    bool clearUpdatingId = false,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      updatingId: clearUpdatingId ? null : (updatingId ?? this.updatingId),
    );
  }
}

class AdminUsersController extends StateNotifier<AdminUsersState> {
  final GetUsersUseCase _getUsersUseCase;
  final BlockUserUseCase _blockUserUseCase;
  final UnblockUserUseCase _unblockUserUseCase;

  AdminUsersController(this._getUsersUseCase, this._blockUserUseCase, this._unblockUserUseCase)
      : super(const AdminUsersState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _getUsersUseCase();
      state = state.copyWith(users: users, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: ApiException.extractMessage(error));
    }
  }

  Future<void> toggle(UserModeration user) async {
    state = state.copyWith(updatingId: user.id);
    try {
      if (user.isActive) {
        await _blockUserUseCase(user.id);
      } else {
        await _unblockUserUseCase(user.id);
      }

      // обновляем конкретный элемент на месте, не трогая порядок списка
      final updatedUsers = state.users.map((u) {
        if (u.id != user.id) return u;
        return UserModeration(id: u.id, email: u.email, role: u.role, isActive: !u.isActive);
      }).toList();

      state = state.copyWith(users: updatedUsers, clearUpdatingId: true);
    } catch (error) {
      state = state.copyWith(clearUpdatingId: true);
      rethrow;
    }
  }
}

final adminUsersControllerProvider = StateNotifierProvider.autoDispose<AdminUsersController, AdminUsersState>(
  (ref) => AdminUsersController(
    ref.read(getUsersUseCaseProvider),
    ref.read(blockUserUseCaseProvider),
    ref.read(unblockUserUseCaseProvider),
  ),
);