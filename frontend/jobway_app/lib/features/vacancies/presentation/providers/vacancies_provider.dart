// features/vacancies/presentation/providers/vacancies_provider.dart — заменить целиком
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/vacancies_remote_data_source.dart';
import '../../data/repository/vacancies_repository_impl.dart';
import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../../domain/repository/vacancies_repository.dart';
import '../../domain/usecases/close_vacancy_usecase.dart';
import '../../domain/usecases/create_vacancy_usecase.dart';
import '../../domain/usecases/get_active_vacancies_usecase.dart';
import '../../domain/usecases/get_my_vacancies_usecase.dart';
import '../../domain/usecases/get_vacancy_by_id_usecase.dart';
import '../../domain/usecases/publish_vacancy_usecase.dart';

final vacanciesRemoteDataSourceProvider = Provider(
  (ref) => VacanciesRemoteDataSource(ref.read(dioClientProvider).dio),
);

final vacanciesRepositoryProvider = Provider<VacanciesRepository>(
  (ref) => VacanciesRepositoryImpl(ref.read(vacanciesRemoteDataSourceProvider)),
);

final getActiveVacanciesUseCaseProvider =
    Provider((ref) => GetActiveVacanciesUseCase(ref.read(vacanciesRepositoryProvider)));

final getVacancyByIdUseCaseProvider =
    Provider((ref) => GetVacancyByIdUseCase(ref.read(vacanciesRepositoryProvider)));

final getMyVacanciesUseCaseProvider =
    Provider((ref) => GetMyVacanciesUseCase(ref.read(vacanciesRepositoryProvider)));

final createVacancyUseCaseProvider =
    Provider((ref) => CreateVacancyUseCase(ref.read(vacanciesRepositoryProvider)));

final publishVacancyUseCaseProvider =
    Provider((ref) => PublishVacancyUseCase(ref.read(vacanciesRepositoryProvider)));

final closeVacancyUseCaseProvider =
    Provider((ref) => CloseVacancyUseCase(ref.read(vacanciesRepositoryProvider)));

final myVacanciesProvider =
    FutureProvider.autoDispose<List<Vacancy>>((ref) => ref.read(getMyVacanciesUseCaseProvider)());

// --- существующее (список активных вакансий для кандидата) ---

class VacanciesState {
  final List<Vacancy> items;
  final VacancyFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const VacanciesState({
    this.items = const [],
    this.filter = const VacancyFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  VacanciesState copyWith({
    List<Vacancy>? items,
    VacancyFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return VacanciesState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class VacanciesController extends StateNotifier<VacanciesState> {
  final GetActiveVacanciesUseCase _getActiveVacanciesUseCase;

  VacanciesController(this._getActiveVacanciesUseCase) : super(const VacanciesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = await _getActiveVacanciesUseCase(state.filter.copyWith(pageNumber: 1));
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        filter: state.filter.copyWith(pageNumber: 1),
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: ApiException.extractMessage(error));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.filter.pageNumber + 1;
      final page = await _getActiveVacanciesUseCase(state.filter.copyWith(pageNumber: nextPage));
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
        filter: state.filter.copyWith(pageNumber: nextPage),
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyFilter(VacancyFilter filter) {
    state = state.copyWith(filter: filter);
    load();
  }
}

final vacanciesControllerProvider = StateNotifierProvider.autoDispose<VacanciesController, VacanciesState>(
  (ref) => VacanciesController(ref.read(getActiveVacanciesUseCaseProvider)),
);

final vacancyDetailProvider =
    FutureProvider.autoDispose.family<Vacancy, String>((ref, id) => ref.read(getVacancyByIdUseCaseProvider)(id));