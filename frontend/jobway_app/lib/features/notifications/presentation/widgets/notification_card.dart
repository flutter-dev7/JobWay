import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../../domain/entities/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  static const _blue = Color(0xFF3157D5);
  static const _green = Color(0xFF059669);
  static const _amber = Color(0xFFD97706);
  static const _star = Color(0xFFF59E0B);
  static const _red = Color(0xFFDC2626);
  static const _gray = Color(0xFF6B7280);

  ({IconData icon, Color color}) _style() {
    switch (notification.type) {
      case 'NewApplication':
        return (icon: Icons.person_add_outlined, color: _blue);
      case 'ApplicationStatusChanged':
        return (icon: Icons.event_available_outlined, color: _green);
      case 'NewMatchingVacancy':
        return (icon: Icons.notifications_active_outlined, color: _amber);
      case 'NewReview':
        return (icon: Icons.star_outline_rounded, color: _star);
      case 'ReviewReminder':
        return (icon: Icons.rate_review_outlined, color: _star);
      case 'NewMessage':
        return (icon: Icons.send_rounded, color: _blue);
      case 'NewEmployerRegistered':
        return (icon: Icons.business_rounded, color: _blue);
      case 'CompanyVerified':
        return (icon: Icons.verified_outlined, color: _green);
      case 'CompanyRejected':
        return (icon: Icons.gpp_bad_outlined, color: _red);
      case 'SubscriptionChanged':
        return (icon: Icons.workspace_premium_outlined, color: _star);
      case 'VacancyPromoted':
        return (icon: Icons.bolt_rounded, color: _amber);
      case 'VacancyExpiring':
        return (icon: Icons.hourglass_bottom_rounded, color: _amber);
      case 'VacancyExpired':
        return (icon: Icons.event_busy_outlined, color: _red);
      case 'AccountBlocked':
        return (icon: Icons.block_rounded, color: _red);
      case 'AccountUnblocked':
        return (icon: Icons.lock_open_rounded, color: _green);
      case 'InvitationReceived':
        return (icon: Icons.mark_email_unread_outlined, color: _blue);
      case 'InvitationDeclined':
        return (icon: Icons.person_off_outlined, color: _gray);
      default:
        return (icon: Icons.info_outline, color: _gray);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = _style();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? colors.surface : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: style.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(style.icon, size: 20, color: style.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    TimeAgo.format(notification.createdAt),
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: context.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
