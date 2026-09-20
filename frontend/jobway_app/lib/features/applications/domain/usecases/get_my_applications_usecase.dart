import '../entities/job_application.dart';
import '../repository/applications_repository.dart';

class GetMyApplicationsUseCase {
  final ApplicationsRepository _repository;

  GetMyApplicationsUseCase(this._repository);

  Future<List<JobApplication>> call() => _repository.getMyApplications();
}