import '../entities/job_application.dart';
import '../repository/applications_repository.dart';

class GetVacancyApplicationsUseCase {
  final ApplicationsRepository _repository;

  GetVacancyApplicationsUseCase(this._repository);

  Future<List<JobApplication>> call(String vacancyId) => _repository.getByVacancy(vacancyId);
}