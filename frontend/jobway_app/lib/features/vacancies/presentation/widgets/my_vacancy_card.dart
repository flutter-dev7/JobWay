// features/vacancies/presentation/widgets/my_vacancy_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../domain/entities/vacancy.dart';

class MyVacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isUpdating;

  const MyVacancyCard({
    super.key,
    required this.vacancy,
    this.onPublish,
    this.onClose,
    this.onTap,
    this.onEdit,
    this.isUpdating = false,
  });

  Color _statusColor() {
    switch (vacancy.status) {
      case 'Active':
        return const Color(0xFF059669);
      case 'Closed':
        return const Color(0xFF6B7280);
      case 'Archived':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel() {
    switch (vacancy.status) {
      case 'Draft':
        return 'Черновик';
      case 'Active':
        return 'Активна';
      case 'Closed':
        return 'Закрыта';
      case 'Archived':
        return 'В архиве';
      default:
        return vacancy.status;
    }
  }

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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _statusColor();
    final showActions = vacancy.status == 'Draft' || vacancy.status == 'Active';

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
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vacancy.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
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
            const SizedBox(height: 14),
            Divider(height: 1, color: colors.border),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Изменить'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.textPrimary,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(width: 10),
                  if (vacancy.status == 'Draft')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUpdating ? null : onPublish,
                        icon: const Icon(
                          Icons.rocket_launch_outlined,
                          size: 16,
                        ),
                        label: const Text('Опубликовать'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textPrimary,
                          side: BorderSide(color: colors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  if (vacancy.status == 'Active')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUpdating ? null : onClose,
                        icon: const Icon(Icons.lock_outline_rounded, size: 16),
                        label: const Text('Закрыть'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
            if (!showActions) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Смотреть отклики',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.accentColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: context.accentColor,
                  ),
                ],
              ),
            ],
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
