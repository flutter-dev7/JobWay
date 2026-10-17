import '../../domain/entities/application_filter.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/entities/paged_job_applications.dart';
import '../../domain/repository/applications_repository.dart';
import '../datasources/applications_remote_data_source.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsRemoteDataSource _remoteDataSource;

  ApplicationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<JobApplication> apply(String vacancyId, {String? coverMessage}) async {
    final model = await _remoteDataSource.apply(vacancyId, coverMessage: coverMessage);
    return model.toEntity();
  }

  @override
  Future<PagedJobApplications> getMyApplications(ApplicationFilter filter) async {
    final model = await _remoteDataSource.getMyApplications(filter);
    return model.toEntity();
  }

  @override
  Future<List<String>> getMyAppliedVacancyIds() => _remoteDataSource.getMyAppliedVacancyIds();

  @override
  Future<PagedJobApplications> getByVacancy(String vacancyId, ApplicationFilter filter) async {
    final model = await _remoteDataSource.getByVacancy(vacancyId, filter);
    return model.toEntity();
  }

  @override
  Future<JobApplication> updateStatus(String applicationId, String status) async {
    final model = await _remoteDataSource.updateStatus(applicationId, status);
    return model.toEntity();
  }
}