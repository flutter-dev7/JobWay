// features/applications/presentation/pages/vacancy_applications_page.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_snackbar.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.vacancyTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
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
              ? const Center(
                  child: Text(
                    'Пока нет откликов',
                    style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    Text(
                      '${applications.length} ${applications.length == 1 ? "отклик" : "откликов"}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
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
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
