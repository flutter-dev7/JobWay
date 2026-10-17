import '../entities/application_filter.dart';
import '../entities/paged_job_applications.dart';
import '../repository/applications_repository.dart';

class GetVacancyApplicationsUseCase {
  final ApplicationsRepository _repository;

  GetVacancyApplicationsUseCase(this._repository);

  Future<PagedJobApplications> call(String vacancyId, ApplicationFilter filter) =>
      _repository.getByVacancy(vacancyId, filter);
}