import '../../domain/entities/vacancies_page.dart';
import '../../domain/entities/vacancy.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../../domain/repository/vacancies_repository.dart';
import '../datasources/vacancies_remote_data_source.dart';

class VacanciesRepositoryImpl implements VacanciesRepository {
  final VacanciesRemoteDataSource _remoteDataSource;

  VacanciesRepositoryImpl(this._remoteDataSource);

  @override
  Future<VacanciesPage> getActive(VacancyFilter filter) async {
    final response = await _remoteDataSource.getActive(filter.toQueryParams());
    return VacanciesPage(
      items: response.items.map((m) => m.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<Vacancy> getById(String id) async {
    final model = await _remoteDataSource.getById(id);
    return model.toEntity();
  }
}