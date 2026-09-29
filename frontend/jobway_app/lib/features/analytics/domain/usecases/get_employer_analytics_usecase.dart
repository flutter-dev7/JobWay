import '../entities/employer_analytics.dart';
import '../repository/analytics_repository.dart';

class GetEmployerAnalyticsUseCase {
  final AnalyticsRepository _repository;

  GetEmployerAnalyticsUseCase(this._repository);

  Future<EmployerAnalytics> call() => _repository.getEmployerAnalytics();
}