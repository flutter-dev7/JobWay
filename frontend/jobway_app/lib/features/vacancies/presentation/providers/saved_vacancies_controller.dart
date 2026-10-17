import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../../domain/usecases/get_saved_vacancies_usecase.dart';
import 'vacancies_provider.dart';

class SavedVacanciesState {
  final List<Vacancy> items;
  final VacancyFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const SavedVacanciesState({
    this.items = const [],
    this.filter = const VacancyFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  SavedVacanciesState copyWith({
    List<Vacancy>? items,
    VacancyFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return SavedVacanciesState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class SavedVacanciesController extends StateNotifier<SavedVacanciesState> {
  final GetSavedVacanciesUseCase _getSaved;
  int _requestId = 0;

  SavedVacanciesController(this._getSaved) : super(const SavedVacanciesState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final filter = state.filter.copyWith(pageNumber: 1);
      final page = await _getSaved(filter);
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
      final page = await _getSaved(filter);
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
}

final savedVacanciesControllerProvider =
    StateNotifierProvider.autoDispose<SavedVacanciesController, SavedVacanciesState>(
  (ref) => SavedVacanciesController(ref.read(getSavedVacanciesUseCaseProvider)),
);