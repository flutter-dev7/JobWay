import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class RenewVacancyUseCase {
  final VacanciesRepository _repository;

  RenewVacancyUseCase(this._repository);

  Future<Vacancy> call(String id) => _repository.renew(id);
}