import '../entities/application_filter.dart';
import '../entities/paged_job_applications.dart';
import '../repository/applications_repository.dart';

class GetMyApplicationsUseCase {
  final ApplicationsRepository _repository;

  GetMyApplicationsUseCase(this._repository);

  Future<PagedJobApplications> call(ApplicationFilter filter) =>
      _repository.getMyApplications(filter);
}