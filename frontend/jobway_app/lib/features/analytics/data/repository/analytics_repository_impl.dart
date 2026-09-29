import '../../domain/entities/employer_analytics.dart';
import '../../domain/repository/analytics_repository.dart';
import '../datasources/analytics_remote_data_source.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;

  AnalyticsRepositoryImpl(this._remoteDataSource);

  @override
  Future<EmployerAnalytics> getEmployerAnalytics() async {
    final model = await _remoteDataSource.getEmployerAnalytics();
    return model.toEntity();
  }
}