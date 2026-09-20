import '../entities/job_application.dart';
import '../repository/applications_repository.dart';

class UpdateApplicationStatusUseCase {
  final ApplicationsRepository _repository;

  UpdateApplicationStatusUseCase(this._repository);

  Future<JobApplication> call(String applicationId, String status) =>
      _repository.updateStatus(applicationId, status);
}