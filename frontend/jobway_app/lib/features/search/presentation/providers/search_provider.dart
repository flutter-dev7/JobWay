import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/company_profile/domain/entities/company_profile.dart';
import 'package:jobway_app/features/vacancies/domain/entities/vacancy.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/search_remote_data_source.dart';
import '../../domain/entities/candidate_search_item.dart';
import '../../domain/entities/company_search_item.dart';
import 'search_list_controller.dart';

final searchRemoteDataSourceProvider = Provider(
  (ref) => SearchRemoteDataSource(ref.read(dioClientProvider).dio),
);

// Поиск компаний (кандидат): фильтр 'withVacancies' показывает только компании с открытыми вакансиями
final companySearchControllerProvider = StateNotifierProvider.autoDispose<
    SearchListController<CompanySearchItem>, SearchState<CompanySearchItem>>((ref) {
  final dataSource = ref.read(searchRemoteDataSourceProvider);
  return SearchListController<CompanySearchItem>(({
    required String query,
    String? filter,
    required int pageNumber,
  }) => dataSource.searchCompanies(
    query: query,
    onlyWithVacancies: filter == 'withVacancies',
    pageNumber: pageNumber,
  ));
});

// Поиск кандидатов (работодатель): фильтр это сфера
final candidateSearchControllerProvider = StateNotifierProvider.autoDispose<
    SearchListController<CandidateSearchItem>, SearchState<CandidateSearchItem>>((ref) {
  final dataSource = ref.read(searchRemoteDataSourceProvider);
  return SearchListController<CandidateSearchItem>(({
    required String query,
    String? filter,
    required int pageNumber,
  }) => dataSource.searchCandidates(
    query: query,
    category: filter,
    pageNumber: pageNumber,
  ));
});

final publicCompanyProvider = FutureProvider.autoDispose.family<CompanyProfile, String>(
  (ref, id) => ref.read(searchRemoteDataSourceProvider).getCompany(id),
);

final publicCompanyVacanciesProvider = FutureProvider.autoDispose.family<List<Vacancy>, String>(
  (ref, id) => ref.read(searchRemoteDataSourceProvider).getCompanyVacancies(id),
);

final profileVisibilityProvider = FutureProvider.autoDispose<bool?>((ref) async {
  try {
    return await ref.read(searchRemoteDataSourceProvider).getVisibility();
  } catch (_) {
    return null;
  }
});