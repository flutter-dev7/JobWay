import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/application_filter.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/usecases/get_vacancy_applications_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';
import 'applications_provider.dart';

class VacancyApplicationsState {
  final List<JobApplication> items;
  final ApplicationFilter filter;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const VacancyApplicationsState({
    this.items = const [],
    this.filter = const ApplicationFilter(),
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  VacancyApplicationsState copyWith({
    List<JobApplication>? items,
    ApplicationFilter? filter,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return VacancyApplicationsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class VacancyApplicationsController extends StateNotifier<VacancyApplicationsState> {
  final String _vacancyId;
  final GetVacancyApplicationsUseCase _getApplications;
  final UpdateApplicationStatusUseCase _updateStatus;
  int _requestId = 0;

  VacancyApplicationsController(
    this._vacancyId,
    this._getApplications,
    this._updateStatus,
  ) : super(const VacancyApplicationsState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final filter = state.filter.copyWith(pageNumber: 1);
      final page = await _getApplications(_vacancyId, filter);
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        totalCount: page.totalCount,
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
      final page = await _getApplications(_vacancyId, filter);
      if (requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        totalCount: page.totalCount,
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

  void applySort(String sortBy) {
    if (sortBy == state.filter.sortBy) return;
    state = state.copyWith(
      filter: state.filter.copyWith(sortBy: sortBy),
      items: const [],
      hasMore: true,
    );
    load();
  }

  // Обновляет статус и правит список на месте, без перезагрузки загруженных страниц
  Future<void> updateStatus(String applicationId, String status) async {
    final updated = await _updateStatus(applicationId, status);

    final filterStatus = state.filter.status;
    final leavesFilter = filterStatus != null && updated.status != filterStatus;

    if (leavesFilter) {
      state = state.copyWith(
        items: state.items.where((a) => a.id != updated.id).toList(),
        totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
      );
    } else {
      state = state.copyWith(
        items: state.items.map((a) => a.id == updated.id ? updated : a).toList(),
      );
    }
  }
}

final vacancyApplicationsControllerProvider = StateNotifierProvider.autoDispose
    .family<VacancyApplicationsController, VacancyApplicationsState, String>(
  (ref, vacancyId) => VacancyApplicationsController(
    vacancyId,
    ref.read(getVacancyApplicationsUseCaseProvider),
    ref.read(updateApplicationStatusUseCaseProvider),
  ),
);