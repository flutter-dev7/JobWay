import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/employer_analytics.dart';

String vacancyStatusLabel(String status) => switch (status) {
      'Draft' => 'Черновик',
      'Active' => 'Активна',
      'Closed' => 'Закрыта',
      'Archived' => 'В архиве',
      _ => status,
    };

class VacancyAnalyticsCard extends StatelessWidget {
  final VacancyAnalyticsItem item;

  const VacancyAnalyticsCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final matchFraction = (item.averageMatchScore / 100).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    vacancyStatusLabel(item.status),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${item.applicationsCount} откликов',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.bolt_outlined, size: 16, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Match ${item.averageMatchScore.round()}%',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: matchFraction == 0 ? 0.02 : matchFraction,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}