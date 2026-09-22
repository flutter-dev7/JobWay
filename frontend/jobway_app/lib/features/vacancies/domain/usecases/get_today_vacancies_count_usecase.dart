import '../repository/vacancies_repository.dart';

class GetTodayVacanciesCountUseCase {
  final VacanciesRepository _repository;
  GetTodayVacanciesCountUseCase(this._repository);
  Future<int> call() => _repository.getTodayCount();
}