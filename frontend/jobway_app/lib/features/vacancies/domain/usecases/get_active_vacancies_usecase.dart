import '../entities/vacancies_page.dart';
import '../entities/vacancy_filter.dart';
import '../repository/vacancies_repository.dart';

class GetActiveVacanciesUseCase {
  final VacanciesRepository _repository;

  GetActiveVacanciesUseCase(this._repository);

  Future<VacanciesPage> call(VacancyFilter filter) => _repository.getActive(filter);
}