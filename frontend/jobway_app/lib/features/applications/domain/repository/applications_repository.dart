import '../entities/application_filter.dart';
import '../entities/job_application.dart';
import '../entities/paged_job_applications.dart';

abstract class ApplicationsRepository {
  Future<JobApplication> apply(String vacancyId, {String? coverMessage});
  Future<PagedJobApplications> getMyApplications(ApplicationFilter filter);
  Future<List<String>> getMyAppliedVacancyIds();
  Future<PagedJobApplications> getByVacancy(String vacancyId, ApplicationFilter filter);
  Future<JobApplication> updateStatus(String applicationId, String status);
}