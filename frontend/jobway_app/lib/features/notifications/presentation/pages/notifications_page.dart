import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../domain/entities/notification.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

class _NotificationCategory {
  final String label;
  final Set<String>? types;

  const _NotificationCategory({required this.label, required this.types});
}

const _categories = [
  _NotificationCategory(label: 'Все', types: null),
  _NotificationCategory(
    label: 'Отклики',
    types: {'NewApplication', 'ApplicationStatusChanged'},
  ),
  _NotificationCategory(
    label: 'Отзывы',
    types: {'NewReview', 'ReviewReminder'},
  ),
  _NotificationCategory(label: 'Вакансии', types: {'NewMatchingVacancy'}),
  _NotificationCategory(label: 'Система', types: {'System'}),
];

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  int _selectedCategory = 0;

  List<AppNotification> _filtered(List<AppNotification> all) {
    final types = _categories[_selectedCategory].types;
    if (types == null) return all;
    return all.where((n) => types.contains(n.type)).toList();
  }

  int _countFor(List<AppNotification> all, Set<String>? types) {
    if (types == null) return all.length;
    return all.where((n) => types.contains(n.type)).length;
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final hasUnread =
        notificationsAsync.valueOrNull?.any((n) => !n.isRead) ?? false;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(
        context,
        'Уведомления',
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () async {
                try {
                  await ref
                      .read(markAllNotificationsReadUseCaseProvider)
                      .call();
                  ref.invalidate(myNotificationsProvider);
                } catch (error) {
                  AppSnackbar.showError(ApiException.extractMessage(error));
                }
              },
              style: TextButton.styleFrom(foregroundColor: context.accentColor),
              child: const Text(
                'Прочитать все',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (notifications) {
          final filtered = _filtered(notifications);

          return RefreshIndicator(
            onRefresh: () => ref.refresh(myNotificationsProvider.future),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == index;
                      final count = _countFor(notifications, category.types);

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.textPrimary
                                : colors.surface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? colors.surface
                                      : colors.textSecondary,
                                ),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colors.surface.withOpacity(0.2)
                                        : colors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? colors.surface
                                          : colors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'Уведомлений нет',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final notification = filtered[index];
                            return NotificationCard(
                              notification: notification,
                              onTap: () async {
                                if (!notification.isRead) {
                                  await ref
                                      .read(markNotificationReadUseCaseProvider)
                                      .call(notification.id);
                                  ref.invalidate(myNotificationsProvider);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
