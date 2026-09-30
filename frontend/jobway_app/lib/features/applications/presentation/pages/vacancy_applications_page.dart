import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import 'package:jobway_app/features/review/presentation/widgets/review_bottom_sheet.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/applications_provider.dart';
import '../widgets/vacancy_application_card.dart';

class VacancyApplicationsPage extends ConsumerStatefulWidget {
  final String vacancyId;
  final String vacancyTitle;
  final String vacancyStatus;

  const VacancyApplicationsPage({
    super.key,
    required this.vacancyId,
    required this.vacancyTitle,
    required this.vacancyStatus,
  });

  @override
  ConsumerState<VacancyApplicationsPage> createState() =>
      _VacancyApplicationsPageState();
}

class _VacancyApplicationsPageState
    extends ConsumerState<VacancyApplicationsPage> {
  String? _updatingApplicationId;

  Future<void> _updateStatus(String applicationId, String status) async {
    setState(() => _updatingApplicationId = applicationId);
    try {
      await ref
          .read(updateApplicationStatusUseCaseProvider)
          .call(applicationId, status);
      ref.invalidate(vacancyApplicationsProvider(widget.vacancyId));
      AppSnackbar.showSuccess('Статус обновлён');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingApplicationId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(
      vacancyApplicationsProvider(widget.vacancyId),
    );
    final isLocked = widget.vacancyStatus != 'Active';
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, widget.vacancyTitle),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.invalidate(vacancyApplicationsProvider(widget.vacancyId)),
        child: applicationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                ApiException.extractMessage(error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (applications) => applications.isEmpty
              ? const EmptyState(
                  icon: Icons.people_outline_rounded,
                  title: 'Пока нет откликов',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    Text(
                      '${applications.length} ${applications.length == 1 ? "отклик" : "откликов"}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...applications.map(
                      (application) => VacancyApplicationCard(
                        application: application,
                        isUpdating: _updatingApplicationId == application.id,
                        isLocked: isLocked,
                        onStatusChanged: (status) =>
                            _updateStatus(application.id, status),
                        onMessage: application.candidateAccountDeleted
                            ? null
                            : () async {
                                await context.push(
                                  AppRoutes.chat(application.id),
                                  extra: ChatArgs(
                                    otherUserId: application.candidateProfileId,
                                    otherUserName:
                                        application.candidateFullName,
                                    otherUserPhotoUrl:
                                        application.candidatePhotoUrl,
                                    vacancyTitle: application.vacancyTitle,
                                  ),
                                );
                              },
                        onLeaveReview: () => ReviewBottomSheet.show(
                          context,
                          jobApplicationId: application.id,
                          targetName: application.candidateFullName,
                          onSubmitted: () => ref.invalidate(
                            vacancyApplicationsProvider(widget.vacancyId),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
