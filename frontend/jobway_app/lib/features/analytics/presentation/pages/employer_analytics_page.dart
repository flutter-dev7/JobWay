import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../subscription/presentation/widgets/pro_locked.dart';
import '../../../subscription/presentation/widgets/subscription_sheet.dart';
import '../../domain/entities/employer_analytics.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_badge.dart';
import '../widgets/analytics_section.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/analytics_trend_chart.dart';
import '../widgets/vacancy_analytics_card.dart';

class EmployerAnalyticsPage extends ConsumerWidget {
  const EmployerAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(employerAnalyticsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Аналитика',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(employerAnalyticsProvider.future),
        child: analyticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text(
                  ApiException.extractMessage(error),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          data: (analytics) => _EmployerAnalyticsBody(analytics: analytics),
        ),
      ),
    );
  }
}

class _EmployerAnalyticsBody extends StatelessWidget {
  final EmployerAnalytics analytics;

  const _EmployerAnalyticsBody({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLimited = analytics.isLimited;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: AnalyticsStatCard(
                label: 'Вакансий',
                value: '${analytics.totalVacancies}',
                icon: LucideIcons.briefcase,
                accentColor: context.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsStatCard(
                label: 'Активных',
                value: '${analytics.activeVacancies}',
                icon: Icons.check_circle_outline_rounded,
                accentColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsStatCard(
                label: 'Откликов',
                value: '${analytics.totalApplications}',
                icon: Icons.people_outline_rounded,
                accentColor: AppColors.star,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: isLimited ? () => SubscriptionSheet.show(context) : null,
                child: AnalyticsStatCard(
                  label: 'Средний Match Score',
                  value: isLimited
                      ? '—'
                      : '${analytics.averageMatchScore.round()}%',
                  icon: isLimited
                      ? Icons.lock_outline_rounded
                      : Icons.bolt_outlined,
                  accentColor: isLimited
                      ? AppColors.warning
                      : context.accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ProLocked(
          locked: isLimited,
          title: 'Воронка по статусам',
          description:
              'Сколько откликов на каждом этапе. Доступно на тарифе Pro',
          child: SectionCard(
            title: 'Воронка по статусам',
            icon: Icons.filter_alt_outlined,
            trailing: const AnalyticsBadge('Всего'),
            child: analytics.statusFunnel.isEmpty
                ? const AnalyticsEmptyHint('Пока нет откликов')
                : AnalyticsTrendChart(
                    lineColor: context.accentColor,
                    points: analytics.statusFunnel
                        .map(
                          (item) => AnalyticsTrendPoint(
                            label: applicationStatusLabel(item.status),
                            value: item.count,
                            color: applicationStatusColor(item.status),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        ProLocked(
          locked: isLimited,
          title: 'Топ навыков соискателей',
          description:
              'Какие навыки чаще всего у откликнувшихся. Доступно на тарифе Pro',
          child: SectionCard(
            title: 'Топ навыков соискателей',
            icon: Icons.star_outline_rounded,
            trailing: const AnalyticsBadge('Топ-5'),
            child: analytics.topSkills.isEmpty
                ? const AnalyticsEmptyHint('Пока нет данных')
                : AnalyticsTrendChart(
                    lineColor: AppColors.star,
                    points: analytics.topSkills
                        .map(
                          (item) => AnalyticsTrendPoint(
                            label: item.nameRu,
                            value: item.count,
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'По вакансиям',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (analytics.vacancies.isEmpty)
          const AnalyticsEmptyHint('Нет вакансий')
        else
          ...analytics.vacancies.map(
            (item) => VacancyAnalyticsCard(item: item, matchLocked: isLimited),
          ),
      ],
    );
  }
}
