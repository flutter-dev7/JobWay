import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../providers/subscription_provider.dart';
import 'subscription_sheet.dart';

class SubscriptionCard extends ConsumerWidget {
  final String companyName;

  const SubscriptionCard({super.key, this.companyName = ''});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider).valueOrNull;
    // Ошибка или загрузка не должны ломать страницу профиля
    if (subscription == null) return const SizedBox.shrink();

    final colors = context.colors;
    const proColor = Color(0xFFF59E0B);
    final tierColor = subscription.isPro ? proColor : colors.textSecondary;
    final limitColor = subscription.isLimitReached
        ? const Color(0xFFDC2626)
        : context.accentColor;
    final progress = subscription.activeVacanciesLimit == 0
        ? 0.0
        : (subscription.activeVacanciesCount / subscription.activeVacanciesLimit)
              .clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => SubscriptionSheet.show(context, companyName: companyName),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
              ),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.workspace_premium_outlined,
                size: 22,
                color: tierColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subscription.isPro ? 'Тариф Pro' : 'Тариф Free',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subscription.isPro && subscription.tierExpiresAt != null
                        ? 'Активен до ${TimeAgo.formatDate(subscription.tierExpiresAt!)}'
                        : 'Активных вакансий: ${subscription.activeVacanciesCount} из ${subscription.activeVacanciesLimit}',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: colors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(limitColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}