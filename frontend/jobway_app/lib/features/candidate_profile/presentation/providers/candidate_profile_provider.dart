// features/candidate_profile/presentation/providers/candidate_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/candidate_profile/domain/usecases/get_candidate_profile_by_id_usecase.dart';
import 'package:jobway_app/features/candidate_profile/domain/usecases/upload_photo_usecase.dart';
import 'package:jobway_app/features/candidate_profile/domain/usecases/upload_resume_usecase.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/candidate_profile_remote_data_source.dart';
import '../../data/repository/candidate_profile_repository_impl.dart';
import '../../domain/entities/candidate_profile.dart';
import '../../domain/repository/candidate_profile_repository.dart';
import '../../domain/usecases/get_candidate_profile_usecase.dart';
import '../../domain/usecases/update_candidate_profile_usecase.dart';

final candidateProfileRemoteDataSourceProvider = Provider(
  (ref) => CandidateProfileRemoteDataSource(ref.read(dioClientProvider).dio),
);

final candidateProfileRepositoryProvider = Provider<CandidateProfileRepository>(
  (ref) => CandidateProfileRepositoryImpl(
    ref.read(candidateProfileRemoteDataSourceProvider),
  ),
);

final getCandidateProfileUseCaseProvider = Provider(
  (ref) =>
      GetCandidateProfileUseCase(ref.read(candidateProfileRepositoryProvider)),
);

final updateCandidateProfileUseCaseProvider = Provider(
  (ref) => UpdateCandidateProfileUseCase(
    ref.read(candidateProfileRepositoryProvider),
  ),
);

final candidateProfileProvider = FutureProvider.autoDispose<CandidateProfile>(
  (ref) => ref.read(getCandidateProfileUseCaseProvider)(),
);

final uploadResumeUseCaseProvider = Provider(
  (ref) => UploadResumeUseCase(ref.read(candidateProfileRepositoryProvider)),
);

final uploadCandidatePhotoUseCaseProvider = Provider(
  (ref) =>
      UploadCandidatePhotoUseCase(ref.read(candidateProfileRepositoryProvider)),
);

final getCandidateProfileByIdUseCaseProvider = Provider(
  (ref) => GetCandidateProfileByIdUseCase(
    ref.read(candidateProfileRepositoryProvider),
  ),
);

final candidateProfileByIdProvider = FutureProvider.autoDispose
    .family<CandidateProfile, String>(
      (ref, id) => ref.read(getCandidateProfileByIdUseCaseProvider)(id),
    );
