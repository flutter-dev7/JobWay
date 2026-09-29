import '../entities/employer_analytics.dart';

abstract class AnalyticsRepository {
  Future<EmployerAnalytics> getEmployerAnalytics();
}