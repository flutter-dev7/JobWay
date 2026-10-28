import 'package:jobway_app/features/vacancies/domain/entities/my_vacancies_filter.dart';

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
  Future<VacanciesPage> getMyVacancies(MyVacanciesFilter filter) async {
    final response = await _remoteDataSource.getMyVacancies(
      filter.toQueryParams(),
    );
    return VacanciesPage(
      items: response.items.map((m) => m.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<Vacancy> create({
    required String title,
    required String description,
    required String responsibilities,
    required String requirements,
    required String employmentType,
    required String experienceLevel,
    required String paymentType,
    required String currency,
    String? location,
    double? salaryFrom,
    double? salaryTo,
    required List<String> skillIds,
  }) async {
    final model = await _remoteDataSource.create(
      title: title,
      description: description,
      responsibilities: responsibilities,
      requirements: requirements,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      paymentType: paymentType,
      currency: currency,
      location: location,
      salaryFrom: salaryFrom,
      salaryTo: salaryTo,
      skillIds: skillIds,
    );
    return model.toEntity();
  }

  @override
  Future<Vacancy> update(
    String id, {
    required String title,
    required String description,
    required String responsibilities,
    required String requirements,
    required String employmentType,
    required String experienceLevel,
    required String paymentType,
    required String currency,
    String? location,
    double? salaryFrom,
    double? salaryTo,
    required List<String> skillIds,
  }) async {
    final model = await _remoteDataSource.update(
      id,
      title: title,
      description: description,
      responsibilities: responsibilities,
      requirements: requirements,
      employmentType: employmentType,
      experienceLevel: experienceLevel,
      paymentType: paymentType,
      currency: currency,
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
  Future<Vacancy> promote(String id) async {
    final model = await _remoteDataSource.promote(id);
    return model.toEntity();
  }

  @override
  Future<Vacancy> renew(String id) async {
    final model = await _remoteDataSource.renew(id);
    return model.toEntity();
  }

  @override
  Future<int> getTodayCount() => _remoteDataSource.getTodayCount();

  @override
  Future<void> save(String vacancyId) => _remoteDataSource.save(vacancyId);

  @override
  Future<void> unsave(String vacancyId) => _remoteDataSource.unsave(vacancyId);

  @override
  Future<VacanciesPage> getSaved(VacancyFilter filter) async {
    final response = await _remoteDataSource.getSaved(filter.toQueryParams());
    return VacanciesPage(
      items: response.items.map((m) => m.toEntity()).toList(),
      pageNumber: response.pageNumber,
      pageSize: response.pageSize,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<List<String>> getSavedIds() => _remoteDataSource.getSavedIds();
}
