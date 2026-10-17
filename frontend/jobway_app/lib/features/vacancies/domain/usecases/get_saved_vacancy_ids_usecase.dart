import '../repository/vacancies_repository.dart';

class GetSavedVacancyIdsUseCase {
  final VacanciesRepository _repository;
  GetSavedVacancyIdsUseCase(this._repository);
  Future<Set<String>> call() async => (await _repository.getSavedIds()).toSet();
}