import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/analytics_remote_data_source.dart';
import '../../data/repository/analytics_repository_impl.dart';
import '../../domain/entities/employer_analytics.dart';
import '../../domain/repository/analytics_repository.dart';
import '../../domain/usecases/get_employer_analytics_usecase.dart';

final analyticsRemoteDataSourceProvider = Provider(
  (ref) => AnalyticsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => AnalyticsRepositoryImpl(ref.read(analyticsRemoteDataSourceProvider)),
);

final getEmployerAnalyticsUseCaseProvider = Provider(
  (ref) => GetEmployerAnalyticsUseCase(ref.read(analyticsRepositoryProvider)),
);

final employerAnalyticsProvider = FutureProvider.autoDispose<EmployerAnalytics>(
  (ref) => ref.read(getEmployerAnalyticsUseCaseProvider).call(),
);