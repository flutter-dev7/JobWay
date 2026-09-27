import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../providers/vacancies_provider.dart';
import '../widgets/vacancy_card.dart';
import 'vacancy_detail_page.dart';

class SavedVacanciesPage extends ConsumerWidget {
  const SavedVacanciesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedVacanciesProvider);
    final colors = context.colors;

    ref.listen(savedVacanciesProvider, (previous, next) {
      next.whenData((vacancies) {
        ref.read(savedVacancyIdsProvider.notifier).state = vacancies
            .map((v) => v.id)
            .toSet();
      });
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Сохранённые',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(savedVacanciesProvider),
        child: savedAsync.when(
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
                    'Нет сохранённых вакансий',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: vacancies.length,
                  itemBuilder: (context, index) {
                    final vacancy = vacancies[index];
                    return VacancyCard(
                      vacancy: vacancy,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              VacancyDetailPage(vacancyId: vacancy.id),
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
