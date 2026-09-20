import 'package:jobway_app/features/vacancies/domain/entities/vacancy.dart';
import 'package:jobway_app/features/vacancies/domain/repository/vacancies_repository.dart';

class CloseVacancyUseCase {
  final VacanciesRepository _repository;

  CloseVacancyUseCase(this._repository);

  Future<Vacancy> call(String id) => _repository.close(id);
}
