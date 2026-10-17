import '../repository/applications_repository.dart';

class GetMyAppliedVacancyIdsUseCase {
  final ApplicationsRepository _repository;

  GetMyAppliedVacancyIdsUseCase(this._repository);

  Future<Set<String>> call() async => (await _repository.getMyAppliedVacancyIds()).toSet();
}