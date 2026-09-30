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

  IconData _icon() {
    switch (notification.type) {
      case 'NewApplication':
        return Icons.person_add_outlined;
      case 'ApplicationStatusChanged':
        return Icons.event_available_outlined;
      case 'NewMatchingVacancy':
        return Icons.notifications_active_outlined;
      case 'NewReview':
        return Icons.star_outline_rounded;
      case 'ReviewReminder':
        return Icons.rate_review_outlined;
      case 'NewMessage':
        return Icons.send_rounded;
      default:
        return Icons.info_outline;
    }
  }

  Color _iconBackground() {
    switch (notification.type) {
      case 'NewApplication':
        return const Color(0xFFDCE5FF);
      case 'ApplicationStatusChanged':
        return const Color(0xFFDCFCE7);
      case 'NewMatchingVacancy':
        return const Color(0xFFFEF3C7);
      case 'NewReview':
        return const Color(0xFFFEF3C7);
      case 'NewMessage':
        return const Color(0xFFDCE5FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _iconColor() {
    switch (notification.type) {
      case 'NewApplication':
        return const Color(0xFF3157D5);
      case 'ApplicationStatusChanged':
        return const Color(0xFF059669);
      case 'NewMatchingVacancy':
        return const Color(0xFFD97706);
      case 'NewReview':
        return const Color(0xFFF59E0B);
      case 'NewMessage':
        return const Color(0xFF3157D5);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                color: _iconBackground(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon(), size: 20, color: _iconColor()),
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
