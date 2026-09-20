import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final hasUnread = notificationsAsync.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Уведомления',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(markAllNotificationsReadUseCaseProvider).call();
                  ref.invalidate(myNotificationsProvider);
                } catch (error) {
                  AppSnackbar.showError(ApiException.extractMessage(error));
                }
              },
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3157D5)),
              child: const Text('Прочитать все', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myNotificationsProvider),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
          ),
          data: (notifications) => notifications.isEmpty
              ? const Center(child: Text('Уведомлений пока нет', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () async {
                        if (!notification.isRead) {
                          await ref.read(markNotificationReadUseCaseProvider).call(notification.id);
                          ref.invalidate(myNotificationsProvider);
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}