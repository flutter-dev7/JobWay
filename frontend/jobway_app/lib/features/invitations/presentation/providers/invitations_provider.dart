import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/invitations/domain/usecases/get_blocked_invite_vacancies_usecase.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../vacancies/domain/entities/my_vacancies_filter.dart';
import '../../../vacancies/domain/entities/vacancy.dart';
import '../../../vacancies/presentation/providers/vacancies_provider.dart';
import '../../data/datasources/invitations_remote_data_source.dart';
import '../../data/repository/invitations_repository_impl.dart';
import '../../domain/entities/invitation.dart';
import '../../domain/repository/invitations_repository.dart';
import '../../domain/usecases/accept_invitation_usecase.dart';
import '../../domain/usecases/decline_invitation_usecase.dart';
import '../../domain/usecases/get_pending_invitations_usecase.dart';
import '../../domain/usecases/invite_candidate_usecase.dart';

final invitationsRemoteDataSourceProvider = Provider(
  (ref) => InvitationsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final invitationsRepositoryProvider = Provider<InvitationsRepository>(
  (ref) => InvitationsRepositoryImpl(ref.read(invitationsRemoteDataSourceProvider)),
);

final inviteCandidateUseCaseProvider = Provider(
  (ref) => InviteCandidateUseCase(ref.read(invitationsRepositoryProvider)),
);

final getPendingInvitationsUseCaseProvider = Provider(
  (ref) => GetPendingInvitationsUseCase(ref.read(invitationsRepositoryProvider)),
);

final acceptInvitationUseCaseProvider = Provider(
  (ref) => AcceptInvitationUseCase(ref.read(invitationsRepositoryProvider)),
);

final declineInvitationUseCaseProvider = Provider(
  (ref) => DeclineInvitationUseCase(ref.read(invitationsRepositoryProvider)),
);

// Приглашения кандидата, на которые он ещё не ответил
final pendingInvitationsProvider = FutureProvider.autoDispose<List<Invitation>>(
  (ref) => ref.read(getPendingInvitationsUseCaseProvider)(),
);

// Активные вакансии работодателя для выбора в окне приглашения
final inviteVacanciesProvider = FutureProvider.autoDispose<List<Vacancy>>((ref) async {
  final page = await ref.read(getMyVacanciesUseCaseProvider)(
    const MyVacanciesFilter(status: 'Active', pageSize: 50),
  );
  return page.items;
});

final getBlockedInviteVacanciesUseCaseProvider = Provider(
  (ref) => GetBlockedInviteVacanciesUseCase(ref.read(invitationsRepositoryProvider)),
);

// Вакансии, на которые этого кандидата приглашать нельзя: vacancyId -> причина
final inviteBlockedProvider = FutureProvider.autoDispose.family<Map<String, String>, String>(
  (ref, candidateProfileId) =>
      ref.read(getBlockedInviteVacanciesUseCaseProvider)(candidateProfileId),
);