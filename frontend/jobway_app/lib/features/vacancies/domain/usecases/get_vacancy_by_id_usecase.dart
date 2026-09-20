import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class GetVacancyByIdUseCase {
  final VacanciesRepository _repository;

  GetVacancyByIdUseCase(this._repository);

  Future<Vacancy> call(String id) => _repository.getById(id);
}