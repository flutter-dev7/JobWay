import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../review/presentation/providers/reviews_provider.dart';
import '../../domain/entities/vacancy.dart';
import '../providers/vacancies_provider.dart';

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
    if (vacancy.salaryFrom != null)
      return 'от ${vacancy.salaryFrom!.toStringAsFixed(0)} $currency $suffix';
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyAvatar(
                  companyName: vacancy.companyName,
                  logoUrl: vacancy.companyLogoUrl,
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
                              averageAsync.valueOrNull!.toStringAsFixed(1),
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
                    final notifier = ref.read(savedVacancyIdsProvider.notifier);
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
                        notifier.update((state) => {...state, vacancy.id});
                      }
                      ref.invalidate(savedVacanciesProvider);
                    } catch (error) {
                      AppSnackbar.showError(ApiException.extractMessage(error));
                    }
                  },
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22,
                    color: isSaved ? context.accentColor : colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  icon: Icons.work_outline_rounded,
                  label: employmentTypeLabel(vacancy.employmentType),
                ),
                _Tag(
                  icon: Icons.trending_up_rounded,
                  label: experienceLevelLabel(vacancy.experienceLevel),
                ),
                if (vacancy.location != null)
                  _Tag(
                    icon: Icons.location_on_outlined,
                    label: vacancy.location!,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_formatSalary().isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vacancy.paymentType == 'Monthly'
                              ? 'Зарплата в месяц'
                              : 'Оплата',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatSalary(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.accentColor,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                Text(
                  TimeAgo.format(vacancy.createdAt),
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
