import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class GetSavedVacanciesUseCase {
  final VacanciesRepository _repository;
  GetSavedVacanciesUseCase(this._repository);
  Future<List<Vacancy>> call() => _repository.getSaved();
}