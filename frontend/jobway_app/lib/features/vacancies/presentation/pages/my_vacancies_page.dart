import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/navigation/notification_bell.dart';
import 'package:jobway_app/features/applications/presentation/pages/vacancy_applications_page.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/vacancies_provider.dart';
import '../widgets/my_vacancy_card.dart';
import 'create_vacancy_page.dart';

class MyVacanciesPage extends ConsumerStatefulWidget {
  const MyVacanciesPage({super.key});

  @override
  ConsumerState<MyVacanciesPage> createState() => _MyVacanciesPageState();
}

class _MyVacanciesPageState extends ConsumerState<MyVacanciesPage> {
  String? _updatingVacancyId;

  Future<void> _publish(String id) async {
    setState(() => _updatingVacancyId = id);
    try {
      await ref.read(publishVacancyUseCaseProvider).call(id);
      ref.invalidate(myVacanciesProvider);
      AppSnackbar.showSuccess('Вакансия опубликована');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingVacancyId = null);
    }
  }

  Future<void> _close(String id) async {
    setState(() => _updatingVacancyId = id);
    try {
      await ref.read(closeVacancyUseCaseProvider).call(id);
      ref.invalidate(myVacanciesProvider);
      AppSnackbar.showSuccess('Вакансия закрыта');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingVacancyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacanciesAsync = ref.watch(myVacanciesProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мои вакансии',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        actions: [
          const NotificationBell(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(Icons.add, color: colors.textPrimary),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateVacancyPage()));
                ref.invalidate(myVacanciesProvider);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myVacanciesProvider),
        child: vacanciesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center),
            ),
          ),
          data: (vacancies) => vacancies.isEmpty
              ? Center(
                  child: Text('У вас пока нет вакансий', style: TextStyle(fontSize: 14, color: colors.textMuted)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: vacancies.length,
                  itemBuilder: (context, index) {
                    final vacancy = vacancies[index];
                    return MyVacancyCard(
                      vacancy: vacancy,
                      isUpdating: _updatingVacancyId == vacancy.id,
                      onPublish: () => _publish(vacancy.id),
                      onClose: () => _close(vacancy.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VacancyApplicationsPage(
                            vacancyId: vacancy.id,
                            vacancyTitle: vacancy.title,
                            vacancyStatus: vacancy.status,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}