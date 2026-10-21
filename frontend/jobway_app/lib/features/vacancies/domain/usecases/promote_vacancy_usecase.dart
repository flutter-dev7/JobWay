import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class PromoteVacancyUseCase {
  final VacanciesRepository _repository;

  PromoteVacancyUseCase(this._repository);

  Future<Vacancy> call(String id) => _repository.promote(id);
}