import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class PublishVacancyUseCase {
  final VacanciesRepository _repository;

  PublishVacancyUseCase(this._repository);

  Future<Vacancy> call(String id) => _repository.publish(id);
}