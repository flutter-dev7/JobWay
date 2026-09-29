import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../vacancies/presentation/providers/vacancies_provider.dart';

class ApplicationsOverviewPage extends ConsumerWidget {
  const ApplicationsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(myVacanciesProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Отклики',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myVacanciesProvider),
        child: vacanciesAsync.when(
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
          data: (vacancies) => vacancies.isEmpty
              ? Center(
                  child: Text(
                    'У вас пока нет вакансий',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: vacancies.length,
                  itemBuilder: (context, index) {
                    final vacancy = vacancies[index];
                    return GestureDetector(
                      onTap: () => context.push(
                        AppRoutes.vacancyApplications(vacancy.id),
                        extra: VacancyApplicationsArgs(
                          title: vacancy.title,
                          status: vacancy.status,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                Theme.of(context).brightness == Brightness.dark
                                    ? 0.2
                                    : 0.03,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.people_outline_rounded,
                                size: 20,
                                color: context.accentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vacancy.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colors.textMuted,
                            ),
                          ],
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
