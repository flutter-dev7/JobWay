import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class GetMyVacanciesUseCase {
  final VacanciesRepository _repository;

  GetMyVacanciesUseCase(this._repository);

  Future<List<Vacancy>> call() => _repository.getMyVacancies();
}