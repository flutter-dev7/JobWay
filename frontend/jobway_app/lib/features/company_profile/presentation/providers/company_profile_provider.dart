import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/company_profile_remote_data_source.dart';
import '../../data/repository/company_profile_repository_impl.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/repository/company_profile_repository.dart';
import '../../domain/usecases/get_company_profile_usecase.dart';
import '../../domain/usecases/update_company_profile_usecase.dart';

final companyProfileRemoteDataSourceProvider = Provider(
  (ref) => CompanyProfileRemoteDataSource(ref.read(dioClientProvider).dio),
);

final companyProfileRepositoryProvider = Provider<CompanyProfileRepository>(
  (ref) => CompanyProfileRepositoryImpl(ref.read(companyProfileRemoteDataSourceProvider)),
);

final getCompanyProfileUseCaseProvider =
    Provider((ref) => GetCompanyProfileUseCase(ref.read(companyProfileRepositoryProvider)));

final updateCompanyProfileUseCaseProvider =
    Provider((ref) => UpdateCompanyProfileUseCase(ref.read(companyProfileRepositoryProvider)));

final companyProfileProvider =
    FutureProvider.autoDispose<CompanyProfile>((ref) => ref.read(getCompanyProfileUseCaseProvider)());