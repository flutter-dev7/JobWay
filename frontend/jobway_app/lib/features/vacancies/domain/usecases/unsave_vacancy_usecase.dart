import '../repository/vacancies_repository.dart';

class UnsaveVacancyUseCase {
  final VacanciesRepository _repository;
  UnsaveVacancyUseCase(this._repository);
  Future<void> call(String vacancyId) => _repository.unsave(vacancyId);
}