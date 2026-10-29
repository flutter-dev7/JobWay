import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/providers/navigation_providers.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/notifications_controller.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_card.dart';

class _NotificationChip {
  final String label;
  final List<String>? types;
  final bool unreadOnly;

  const _NotificationChip({
    required this.label,
    this.types,
    this.unreadOnly = false,
  });
}

const _chips = [
  _NotificationChip(label: 'Все'),
  _NotificationChip(label: 'Непрочитанные', unreadOnly: true),
  _NotificationChip(
    label: 'Отклики',
    types: [
      'NewApplication',
      'ApplicationStatusChanged',
      'InvitationReceived',
      'InvitationDeclined',
    ],
  ),
  _NotificationChip(
    label: 'Вакансии',
    types: ['NewMatchingVacancy', 'VacancyExpiring', 'VacancyExpired'],
  ),
  _NotificationChip(label: 'Отзывы', types: ['NewReview', 'ReviewReminder']),
  _NotificationChip(label: 'Вакансии', types: ['NewMatchingVacancy']),
  _NotificationChip(
    label: 'Система',
    types: [
      'System',
      'NewEmployerRegistered',
      'CompanyVerified',
      'CompanyRejected',
      'SubscriptionChanged',
      'VacancyPromoted',
      'AccountBlocked',
      'AccountUnblocked',
    ],
  ),
];

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final _scrollController = ScrollController();
  int _selectedChip = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  NotificationsController get _controller =>
      ref.read(notificationsControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  void _selectChip(int index) {
    if (index == _selectedChip) return;
    setState(() => _selectedChip = index);
    final chip = _chips[index];
    _controller.applyFilter(types: chip.types, unreadOnly: chip.unreadOnly);
  }

  Widget _buildChips() {
    final colors = context.colors;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedChip == index;

          return GestureDetector(
            onTap: () => _selectChip(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.textPrimary : colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                _chips[index].label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.surface : colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(state.error!, textAlign: TextAlign.center),
        ],
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(icon: LucideIcons.bell, title: 'Уведомлений нет');
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notification = state.items[index];
        return NotificationCard(
          notification: notification,
          onTap: () async {
            if (!notification.isRead) {
              try {
                await _controller.markRead(notification.id);
              } catch (error) {
                AppSnackbar.showError(ApiException.extractMessage(error));
              }
            }

            if (!mounted) return;

            if (notification.type == 'InvitationReceived') {
              ref.read(homeTabRequestProvider.notifier).state = 3;
              if (context.canPop()) context.pop();
              return;
            }

            final opensVacancies =
                notification.type == 'VacancyExpiring' ||
                notification.type == 'VacancyExpired';

            if (opensVacancies) {
              ref.read(homeTabRequestProvider.notifier).state = 0;
              if (context.canPop()) context.pop();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);
    final unreadCount =
        ref.watch(unreadNotificationsCountProvider).valueOrNull ?? 0;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(
        context,
        'Уведомления',
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () async {
                try {
                  await _controller.markAllRead();
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
      body: Column(
        children: [
          _buildChips(),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(unreadNotificationsCountProvider);
                await _controller.load();
              },
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }
}
