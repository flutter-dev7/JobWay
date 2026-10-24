// features/vacancies/presentation/widgets/my_vacancy_card.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../domain/entities/vacancy.dart';
import 'vacancy_tags_row.dart';
import 'vacancy_top_ribbon.dart';

class MyVacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onPromote;
  final bool promoteLocked;
  final bool isUpdating;

  const MyVacancyCard({
    super.key,
    required this.vacancy,
    this.onPublish,
    this.onClose,
    this.onTap,
    this.onEdit,
    this.onPromote,
    this.promoteLocked = false,
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
    if (vacancy.salaryFrom != null) {
      return 'от ${vacancy.salaryFrom!.toStringAsFixed(0)} $currency $suffix';
    }
    return 'до ${vacancy.salaryTo!.toStringAsFixed(0)} $currency $suffix';
  }

  String _remainingLabel(DateTime until) {
    final diff = until.difference(DateTime.now());
    if (diff.inDays >= 1) return 'ещё ${diff.inDays} дн.';
    if (diff.inHours >= 1) return 'ещё ${diff.inHours} ч.';
    return 'скоро закончится';
  }

  List<Widget> _buildActions(BuildContext context) {
    final colors = context.colors;
    final isFeatured = vacancy.isFeatured;
    final actions = <Widget>[];

        if (vacancy.status == 'Active' && !isFeatured && onPromote != null) {
      actions.add(
        _ActionIcon(
          icon: Icons.bolt_rounded,
          tooltip: promoteLocked
              ? 'Продвинуть в топ (нужен Pro)'
              : 'Продвинуть в топ',
          color: VacancyTopStyle.amberDeep,
          borderColor: const Color(0xFFFDE68A),
          badge: promoteLocked ? 'PRO' : null,
          onPressed: isUpdating ? null : onPromote,
        ),
      );
    }

    actions.add(
      _ActionIcon(
        icon: LucideIcons.pencil,
        tooltip: 'Изменить',
        color: colors.textPrimary,
        borderColor: colors.border,
        onPressed: onEdit,
      ),
    );

    if (vacancy.status == 'Draft') {
      actions.add(
        _ActionIcon(
          icon: LucideIcons.rocket,
          tooltip: 'Опубликовать',
          color: colors.textPrimary,
          borderColor: colors.border,
          onPressed: isUpdating ? null : onPublish,
        ),
      );
    } else if (vacancy.status == 'Active') {
            actions.add(
        _ActionIcon(
          icon: Icons.cancel_outlined,
          tooltip: 'Закрыть вакансию',
          color: const Color(0xFFDC2626),
          borderColor: const Color(0xFFFECACA),
          onPressed: isUpdating ? null : onClose,
        ),
      );
    } else {
      actions.add(
        _ActionIcon(
          icon: LucideIcons.users,
          tooltip: 'Отклики',
          color: colors.textPrimary,
          borderColor: colors.border,
          onPressed: onTap,
        ),
      );
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = _statusColor();
    final isFeatured = vacancy.isFeatured;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final salary = _formatSalary();
    final hasSalary = salary.isNotEmpty;
    final actions = _buildActions(context);

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
                VacancyTopRibbon(
                  title: 'В топе ленты',
                  trailing:
                      'до ${TimeAgo.formatDate(vacancy.featuredUntil!)} · ${_remainingLabel(vacancy.featuredUntil!)}',
                ),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _statusLabel(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
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
                                    color: hasSalary
                                        ? context.accentColor
                                        : colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            actions[i],
                          ],
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

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color borderColor;
  final String? badge;
  final VoidCallback? onPressed;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.borderColor,
    this.badge,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: color,
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(icon, size: 17),
              ),
            ),
            if (badge != null)
              Positioned(
                top: -6,
                right: -6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}