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

  @override
  Future<List<Vacancy>> getMyVacancies() async {
    final models = await _remoteDataSource.getMyVacancies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Vacancy> create({
    required String title,
    required String description,
    required String employmentType,
    required String experienceLevel,
    String? location,
    double? salaryFrom,
    double? salaryTo,
    required List<String> skillIds,
  }) async {
    final model = await _remoteDataSource.create(
      title: title,
      description: description,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      location: location,
      salaryFrom: salaryFrom,
      salaryTo: salaryTo,
      skillIds: skillIds,
    );
    return model.toEntity();
  }

  @override
  Future<Vacancy> publish(String id) async {
    final model = await _remoteDataSource.publish(id);
    return model.toEntity();
  }

  @override
  Future<Vacancy> close(String id) async {
    final model = await _remoteDataSource.close(id);
    return model.toEntity();
  }

  @override
  Future<int> getTodayCount() => _remoteDataSource.getTodayCount();

  @override
  Future<void> save(String vacancyId) => _remoteDataSource.save(vacancyId);

  @override
  Future<void> unsave(String vacancyId) => _remoteDataSource.unsave(vacancyId);

  @override
  Future<List<Vacancy>> getSaved() async {
    final models = await _remoteDataSource.getSaved();
    return models.map((m) => m.toEntity()).toList();
  }
}
