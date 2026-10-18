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

// --- Компании: пагинация, фильтр по статусу, поиск ---

class AdminCompaniesState {
  final List<CompanyModeration> items;
  final String? status;
  final String search;
  final int pageNumber;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? updatingId;

  const AdminCompaniesState({
    this.items = const [],
    this.status,
    this.search = '',
    this.pageNumber = 1,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.updatingId,
  });

  AdminCompaniesState copyWith({
    List<CompanyModeration>? items,
    String? status,
    String? search,
    int? pageNumber,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? updatingId,
    bool clearStatus = false,
    bool clearUpdatingId = false,
  }) {
    return AdminCompaniesState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      search: search ?? this.search,
      pageNumber: pageNumber ?? this.pageNumber,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      updatingId: clearUpdatingId ? null : (updatingId ?? this.updatingId),
    );
  }
}

class AdminCompaniesController extends StateNotifier<AdminCompaniesState> {
  // Админ сразу видит компании, которые ждут решения
  static const defaultStatus = 'NotVerified';

  final GetCompaniesUseCase _getCompanies;
  final VerifyCompanyUseCase _verify;
  final RejectCompanyUseCase _reject;
  int _requestId = 0;

  AdminCompaniesController(this._getCompanies, this._verify, this._reject)
      : super(const AdminCompaniesState(status: defaultStatus)) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final page = await _getCompanies(status: state.status, search: state.search, pageNumber: 1);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        pageNumber: 1,
        totalCount: page.totalCount,
        isLoading: false,
        hasMore: page.hasMore,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoading: false, error: ApiException.extractMessage(error));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.pageNumber + 1;
      final page = await _getCompanies(status: state.status, search: state.search, pageNumber: nextPage);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        pageNumber: nextPage,
        totalCount: page.totalCount,
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyStatus(String? status) {
    if (status == state.status) return;
    state = state.copyWith(
      status: status,
      clearStatus: status == null,
      items: const [],
      hasMore: true,
    );
    load();
  }

  void applySearch(String search) {
    if (search == state.search) return;
    state = state.copyWith(search: search, items: const [], hasMore: true);
    load();
  }

  Future<void> verify(String id) async {
    state = state.copyWith(updatingId: id);
    try {
      await _verify(id);
      if (!mounted) return;
      _applyNewStatus(id, 'Verified');
    } catch (_) {
      if (mounted) state = state.copyWith(clearUpdatingId: true);
      rethrow;
    }
  }

  Future<void> reject(String id) async {
    state = state.copyWith(updatingId: id);
    try {
      await _reject(id);
      if (!mounted) return;
      _applyNewStatus(id, 'Rejected');
    } catch (_) {
      if (mounted) state = state.copyWith(clearUpdatingId: true);
      rethrow;
    }
  }

  // Меняет статус на месте. Если компания больше не подходит под выбранный фильтр, убирает её из списка.
  void _applyNewStatus(String id, String newStatus) {
    final leavesFilter = state.status != null && state.status != newStatus;

    state = state.copyWith(
      items: leavesFilter
          ? state.items.where((c) => c.id != id).toList()
          : state.items
              .map((c) => c.id == id ? c.copyWith(verificationStatus: newStatus) : c)
              .toList(),
      totalCount: leavesFilter && state.totalCount > 0 ? state.totalCount - 1 : state.totalCount,
      clearUpdatingId: true,
    );
  }
}

final adminCompaniesControllerProvider =
    StateNotifierProvider.autoDispose<AdminCompaniesController, AdminCompaniesState>(
  (ref) => AdminCompaniesController(
    ref.read(getCompaniesUseCaseProvider),
    ref.read(verifyCompanyUseCaseProvider),
    ref.read(rejectCompanyUseCaseProvider),
  ),
);

// --- Пользователи: пагинация, фильтр по роли и блокировке, поиск ---

class AdminUsersState {
  final List<UserModeration> users;
  final String? role;
  final bool? isActive;
  final String search;
  final int pageNumber;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String? updatingId;

  const AdminUsersState({
    this.users = const [],
    this.role,
    this.isActive,
    this.search = '',
    this.pageNumber = 1,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.updatingId,
  });

  AdminUsersState copyWith({
    List<UserModeration>? users,
    String? role,
    bool? isActive,
    String? search,
    int? pageNumber,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? updatingId,
    bool clearRole = false,
    bool clearIsActive = false,
    bool clearUpdatingId = false,
  }) {
    return AdminUsersState(
      users: users ?? this.users,
      role: clearRole ? null : (role ?? this.role),
      isActive: clearIsActive ? null : (isActive ?? this.isActive),
      search: search ?? this.search,
      pageNumber: pageNumber ?? this.pageNumber,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      updatingId: clearUpdatingId ? null : (updatingId ?? this.updatingId),
    );
  }
}

class AdminUsersController extends StateNotifier<AdminUsersState> {
  final GetUsersUseCase _getUsers;
  final BlockUserUseCase _block;
  final UnblockUserUseCase _unblock;
  int _requestId = 0;

  AdminUsersController(this._getUsers, this._block, this._unblock)
      : super(const AdminUsersState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final page = await _getUsers(
        role: state.role,
        isActive: state.isActive,
        search: state.search,
        pageNumber: 1,
      );
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        users: page.items,
        pageNumber: 1,
        totalCount: page.totalCount,
        isLoading: false,
        hasMore: page.hasMore,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoading: false, error: ApiException.extractMessage(error));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.pageNumber + 1;
      final page = await _getUsers(
        role: state.role,
        isActive: state.isActive,
        search: state.search,
        pageNumber: nextPage,
      );
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        users: [...state.users, ...page.items],
        pageNumber: nextPage,
        totalCount: page.totalCount,
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyFilter({String? role, bool? isActive}) {
    if (role == state.role && isActive == state.isActive) return;
    state = state.copyWith(
      role: role,
      clearRole: role == null,
      isActive: isActive,
      clearIsActive: isActive == null,
      users: const [],
      hasMore: true,
    );
    load();
  }

  void applySearch(String search) {
    if (search == state.search) return;
    state = state.copyWith(search: search, users: const [], hasMore: true);
    load();
  }

  Future<void> toggle(UserModeration user) async {
    state = state.copyWith(updatingId: user.id);
    try {
      if (user.isActive) {
        await _block(user.id);
      } else {
        await _unblock(user.id);
      }
      if (!mounted) return;

      final newActive = !user.isActive;
      // В фильтре «Заблокированные» разблокированный пользователь уходит из списка
      final leavesFilter = state.isActive != null && state.isActive != newActive;

      state = state.copyWith(
        users: leavesFilter
            ? state.users.where((u) => u.id != user.id).toList()
            : state.users
                .map((u) => u.id == user.id ? u.copyWith(isActive: newActive) : u)
                .toList(),
        totalCount: leavesFilter && state.totalCount > 0 ? state.totalCount - 1 : state.totalCount,
        clearUpdatingId: true,
      );
    } catch (_) {
      if (mounted) state = state.copyWith(clearUpdatingId: true);
      rethrow;
    }
  }
}

final adminUsersControllerProvider =
    StateNotifierProvider.autoDispose<AdminUsersController, AdminUsersState>(
  (ref) => AdminUsersController(
    ref.read(getUsersUseCaseProvider),
    ref.read(blockUserUseCaseProvider),
    ref.read(unblockUserUseCaseProvider),
  ),
);