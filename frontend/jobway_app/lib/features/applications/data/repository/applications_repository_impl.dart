import '../../domain/entities/job_application.dart';
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
  Future<List<JobApplication>> getMyApplications() async {
    final models = await _remoteDataSource.getMyApplications();
    return models.map((m) => m.toEntity()).toList();
  }
}