import '../entities/vacancies_page.dart';
import '../entities/vacancy_filter.dart';
import '../repository/vacancies_repository.dart';

class GetSavedVacanciesUseCase {
  final VacanciesRepository _repository;
  GetSavedVacanciesUseCase(this._repository);
  Future<VacanciesPage> call(VacancyFilter filter) =>
      _repository.getSaved(filter);
}
