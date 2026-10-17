import '../entities/my_vacancies_filter.dart';
import '../entities/vacancies_page.dart';
import '../repository/vacancies_repository.dart';

class GetMyVacanciesUseCase {
  final VacanciesRepository _repository;

  GetMyVacanciesUseCase(this._repository);

  Future<VacanciesPage> call(MyVacanciesFilter filter) => _repository.getMyVacancies(filter);
}