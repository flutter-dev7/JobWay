import '../repository/vacancies_repository.dart';

class SaveVacancyUseCase {
  final VacanciesRepository _repository;
  SaveVacancyUseCase(this._repository);
  Future<void> call(String vacancyId) => _repository.save(vacancyId);
}