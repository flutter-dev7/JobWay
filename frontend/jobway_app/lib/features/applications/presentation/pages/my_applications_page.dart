import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/features/review/presentation/widgets/review_bottom_sheet.dart';
import '../../../../core/network/api_exception.dart';
import '../providers/applications_provider.dart';
import '../widgets/application_card.dart';

class MyApplicationsPage extends ConsumerWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мои отклики',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myApplicationsProvider),
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
              ? Center(
                  child: Text(
                    'Вы ещё не откликались на вакансии',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: applications.length,
                  itemBuilder: (context, index) {
                    final application = applications[index];
                    return ApplicationCard(
                      application: application,
                      onLeaveReview: () => ReviewBottomSheet.show(
                        context,
                        jobApplicationId: application.id,
                        targetName: application.companyName,
                        onSubmitted: () =>
                            ref.invalidate(myApplicationsProvider),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
