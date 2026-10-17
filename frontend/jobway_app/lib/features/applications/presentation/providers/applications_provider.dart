import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/applications_remote_data_source.dart';
import '../../data/repository/applications_repository_impl.dart';
import '../../domain/entities/application_filter.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repository/applications_repository.dart';
import '../../domain/usecases/apply_to_vacancy_usecase.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import '../../domain/usecases/get_my_applied_vacancy_ids_usecase.dart';
import '../../domain/usecases/get_vacancy_applications_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';

final applicationsRemoteDataSourceProvider = Provider(
  (ref) => ApplicationsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final applicationsRepositoryProvider = Provider<ApplicationsRepository>(
  (ref) => ApplicationsRepositoryImpl(ref.read(applicationsRemoteDataSourceProvider)),
);

final applyToVacancyUseCaseProvider = Provider((ref) => ApplyToVacancyUseCase(ref.read(applicationsRepositoryProvider)));

final getMyApplicationsUseCaseProvider =
    Provider((ref) => GetMyApplicationsUseCase(ref.read(applicationsRepositoryProvider)));

final getMyAppliedVacancyIdsUseCaseProvider =
    Provider((ref) => GetMyAppliedVacancyIdsUseCase(ref.read(applicationsRepositoryProvider)));

final getVacancyApplicationsUseCaseProvider =
    Provider((ref) => GetVacancyApplicationsUseCase(ref.read(applicationsRepositoryProvider)));

final updateApplicationStatusUseCaseProvider =
    Provider((ref) => UpdateApplicationStatusUseCase(ref.read(applicationsRepositoryProvider)));


// Id вакансий, на которые откликнулся кандидат (лёгкий запрос, не зависит от пагинации списка)
final myAppliedVacancyIdsProvider = FutureProvider.autoDispose<Set<String>>(
  (ref) => ref.read(getMyAppliedVacancyIdsUseCaseProvider)(),
);

final appliedVacancyIdsProvider = Provider.autoDispose<Set<String>>(
  (ref) => ref.watch(myAppliedVacancyIdsProvider).valueOrNull ?? {},
);

// --- Мои отклики (Candidate): пагинация + фильтр по статусу ---

class MyApplicationsState {
  final List<JobApplication> items;
  final ApplicationFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyApplicationsState({
    this.items = const [],
    this.filter = const ApplicationFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  MyApplicationsState copyWith({
    List<JobApplication>? items,
    ApplicationFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return MyApplicationsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class MyApplicationsController extends StateNotifier<MyApplicationsState> {
  final GetMyApplicationsUseCase _getMyApplications;
  int _requestId = 0;

  MyApplicationsController(this._getMyApplications) : super(const MyApplicationsState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final filter = state.filter.copyWith(pageNumber: 1);
      final page = await _getMyApplications(filter);
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (error) {
      if (requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        error: ApiException.extractMessage(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final filter = state.filter.copyWith(pageNumber: state.filter.pageNumber + 1);
      final page = await _getMyApplications(filter);
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (_) {
      if (requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyStatus(String? status) {
    if (status == state.filter.status) return;
    final filter = status == null
        ? state.filter.copyWith(clearStatus: true)
        : state.filter.copyWith(status: status);
    state = state.copyWith(filter: filter, items: const [], hasMore: true);
    load();
  }
}

final myApplicationsControllerProvider =
    StateNotifierProvider.autoDispose<MyApplicationsController, MyApplicationsState>(
  (ref) => MyApplicationsController(ref.read(getMyApplicationsUseCaseProvider)),
);