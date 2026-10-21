import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/features/vacancies/presentation/providers/saved_vacancies_controller.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../review/presentation/providers/reviews_provider.dart';
import '../../domain/entities/vacancy.dart';
import '../providers/vacancies_provider.dart';
import 'vacancy_tags_row.dart';
import 'vacancy_top_ribbon.dart';

class VacancyCard extends ConsumerWidget {
  final Vacancy vacancy;
  final VoidCallback onTap;

  const VacancyCard({super.key, required this.vacancy, required this.onTap});

  String _formatSalary() {
    if (vacancy.salaryFrom == null && vacancy.salaryTo == null) return '';
    final currency = currencyLabel(vacancy.currency);
    final suffix = paymentTypeLabel(vacancy.paymentType);
    if (vacancy.salaryFrom != null && vacancy.salaryTo != null) {
      return '${vacancy.salaryFrom!.toStringAsFixed(0)} – ${vacancy.salaryTo!.toStringAsFixed(0)} $currency $suffix';
    }
    if (vacancy.salaryFrom != null) {
      return 'от ${vacancy.salaryFrom!.toStringAsFixed(0)} $currency $suffix';
    }
    return 'до ${vacancy.salaryTo!.toStringAsFixed(0)} $currency $suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedVacancyIdsProvider);
    final isSaved = savedIds.contains(vacancy.id);
    final averageAsync = ref.watch(
      averageRatingProvider(vacancy.companyUserId),
    );
    final colors = context.colors;
    final isFeatured = vacancy.isFeatured;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salary = _formatSalary();
    final hasSalary = salary.isNotEmpty;
    final isClosed = vacancy.status != 'Active';

    final cardColor = isFeatured
        ? Color.alphaBlend(
            VacancyTopStyle.amber.withOpacity(isDark ? 0.06 : 0.05),
            colors.surface,
          )
        : colors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isFeatured
              ? Border.all(
                  color: VacancyTopStyle.amber.withOpacity(0.55),
                  width: 1.5,
                )
              : null,
          // Тень одинаковая у всех карточек, без цветного свечения
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isFeatured ? 18.5 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isFeatured)
                const VacancyTopRibbon(title: 'Топ', trailing: 'Продвигается'),
              Padding(
                padding: const EdgeInsets.all(VacancyCardLayout.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: VacancyCardLayout.headerHeight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CompanyAvatar(
                            companyName: vacancy.companyName,
                            logoUrl: vacancy.companyLogoUrl,
                            size: VacancyCardLayout.headerHeight,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vacancy.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        vacancy.companyName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    if (averageAsync.valueOrNull != null &&
                                        averageAsync.valueOrNull! > 0) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        averageAsync.valueOrNull!
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final notifier = ref.read(
                                savedVacancyIdsProvider.notifier,
                              );
                              try {
                                if (isSaved) {
                                  await ref
                                      .read(unsaveVacancyUseCaseProvider)
                                      .call(vacancy.id);
                                  notifier.update(
                                    (state) => {...state}..remove(vacancy.id),
                                  );
                                } else {
                                  await ref
                                      .read(saveVacancyUseCaseProvider)
                                      .call(vacancy.id);
                                  notifier.update(
                                    (state) => {...state, vacancy.id},
                                  );
                                }
                                ref.invalidate(
                                  savedVacanciesControllerProvider,
                                );
                              } catch (error) {
                                AppSnackbar.showError(
                                  ApiException.extractMessage(error),
                                );
                              }
                            },
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              size: 22,
                              color: isSaved
                                  ? context.accentColor
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: VacancyCardLayout.gap),
                    VacancyTagsRow(vacancy: vacancy),
                    const SizedBox(height: VacancyCardLayout.gap),
                    SizedBox(
                      height: VacancyCardLayout.bottomHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasSalary
                                      ? (vacancy.paymentType == 'Monthly'
                                            ? 'Зарплата в месяц'
                                            : 'Оплата')
                                      : 'Зарплата',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasSalary ? salary : 'Не указана',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: hasSalary
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: hasSalary && !isClosed
                                        ? context.accentColor
                                        : colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isClosed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Вакансия закрыта',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            )
                          else
                            Text(
                              TimeAgo.format(vacancy.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
