import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/my_vacancies_filter.dart';
import '../../domain/entities/vacancy.dart';
import '../../domain/usecases/close_vacancy_usecase.dart';
import '../../domain/usecases/get_my_vacancies_usecase.dart';
import '../../domain/usecases/promote_vacancy_usecase.dart';
import '../../domain/usecases/publish_vacancy_usecase.dart';
import 'vacancies_provider.dart';

class MyVacanciesState {
  final List<Vacancy> items;
  final MyVacanciesFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MyVacanciesState({
    this.items = const [],
    this.filter = const MyVacanciesFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  MyVacanciesState copyWith({
    List<Vacancy>? items,
    MyVacanciesFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return MyVacanciesState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class MyVacanciesController extends StateNotifier<MyVacanciesState> {
  final GetMyVacanciesUseCase _getMyVacancies;
  final PublishVacancyUseCase _publish;
  final CloseVacancyUseCase _close;
  final PromoteVacancyUseCase _promote;
  int _requestId = 0;

  MyVacanciesController(
    this._getMyVacancies,
    this._publish,
    this._close,
    this._promote,
  ) : super(const MyVacanciesState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final filter = state.filter.copyWith(pageNumber: 1);
      final page = await _getMyVacancies(filter);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
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
      final filter = state.filter.copyWith(
        pageNumber: state.filter.pageNumber + 1,
      );
      final page = await _getMyVacancies(filter);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
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

  Future<void> publish(String id) async => _applyUpdated(await _publish(id));

  Future<void> close(String id) async => _applyUpdated(await _close(id));

  Future<void> promote(String id) async => _applyUpdated(await _promote(id));

  // Обновляет вакансию в списке на месте. Если она больше не подходит
  // под выбранный статус (например, Draft → Active при фильтре «Черновики»), убирает её.
  void _applyUpdated(Vacancy updated) {
    if (!mounted) return;
    final filterStatus = state.filter.status;
    final leavesFilter = filterStatus != null && updated.status != filterStatus;

    final items = leavesFilter
        ? state.items.where((v) => v.id != updated.id).toList()
        : state.items.map((v) => v.id == updated.id ? updated : v).toList();

    // Тот же порядок, что на сервере: сначала продвигаемые, затем по дате создания
    items.sort((a, b) {
      if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = state.copyWith(items: items);
  }
}

MyVacanciesController _createController(Ref ref) => MyVacanciesController(
  ref.read(getMyVacanciesUseCaseProvider),
  ref.read(publishVacancyUseCaseProvider),
  ref.read(closeVacancyUseCaseProvider),
  ref.read(promoteVacancyUseCaseProvider),
);

final myVacanciesControllerProvider =
    StateNotifierProvider.autoDispose<MyVacanciesController, MyVacanciesState>(
      _createController,
    );

// Отдельный экземпляр для вкладки «Отклики»: свой список и свой фильтр
final applicationsOverviewControllerProvider =
    StateNotifierProvider.autoDispose<MyVacanciesController, MyVacanciesState>(
      _createController,
    );
