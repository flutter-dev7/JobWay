import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/applications_remote_data_source.dart';
import '../../data/repository/applications_repository_impl.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repository/applications_repository.dart';
import '../../domain/usecases/apply_to_vacancy_usecase.dart';
import '../../domain/usecases/get_my_applications_usecase.dart';
import '../../domain/usecases/get_vacancy_applications_usecase.dart';
import '../../domain/usecases/update_application_status_usecase.dart';

final applicationsRemoteDataSourceProvider = Provider(
  (ref) => ApplicationsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final applicationsRepositoryProvider = Provider<ApplicationsRepository>(
  (ref) => ApplicationsRepositoryImpl(ref.read(applicationsRemoteDataSourceProvider)),
);

final applyToVacancyUseCaseProvider = Provider((ref) => ApplyToVacancyUseCase(ref.read(applicationsRepositoryProvider)));

final getMyApplicationsUseCaseProvider =
    Provider((ref) => GetMyApplicationsUseCase(ref.read(applicationsRepositoryProvider)));

final getVacancyApplicationsUseCaseProvider =
    Provider((ref) => GetVacancyApplicationsUseCase(ref.read(applicationsRepositoryProvider)));

final updateApplicationStatusUseCaseProvider =
    Provider((ref) => UpdateApplicationStatusUseCase(ref.read(applicationsRepositoryProvider)));

final myApplicationsProvider =
    FutureProvider.autoDispose<List<JobApplication>>((ref) => ref.read(getMyApplicationsUseCaseProvider)());

final vacancyApplicationsProvider = FutureProvider.autoDispose.family<List<JobApplication>, String>(
  (ref, vacancyId) => ref.read(getVacancyApplicationsUseCaseProvider)(vacancyId),
);