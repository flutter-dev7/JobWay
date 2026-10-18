import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_filter.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notifications_provider.dart';

class NotificationsState {
  final List<AppNotification> items;
  final NotificationFilter filter;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.filter = const NotificationFilter(),
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  NotificationsState copyWith({
    List<AppNotification>? items,
    NotificationFilter? filter,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class NotificationsController extends StateNotifier<NotificationsState> {
  final GetMyNotificationsUseCase _getMy;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final VoidCallback _onUnreadChanged;
  int _requestId = 0;

  NotificationsController(
    this._getMy,
    this._markRead,
    this._markAllRead,
    this._onUnreadChanged,
  ) : super(const NotificationsState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final filter = state.filter.copyWith(pageNumber: 1);
      final page = await _getMy(filter);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        isLoading: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        error: ApiException.extractMessage(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final filter = state.filter.copyWith(pageNumber: state.filter.pageNumber + 1);
      final page = await _getMy(filter);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
        filter: filter,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyFilter({List<String>? types, bool unreadOnly = false}) {
    state = state.copyWith(
      filter: NotificationFilter(types: types, unreadOnly: unreadOnly),
      items: const [],
      hasMore: true,
    );
    load();
  }

  // Помечает прочитанным на месте. В режиме «Непрочитанные» убирает карточку из списка.
  Future<void> markRead(String id) async {
    await _markRead(id);
    if (!mounted) return;
    state = state.copyWith(
      items: state.filter.unreadOnly
          ? state.items.where((n) => n.id != id).toList()
          : state.items
              .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
              .toList(),
    );
    _onUnreadChanged();
  }

  Future<void> markAllRead() async {
    await _markAllRead();
    if (!mounted) return;
    state = state.filter.unreadOnly
        ? state.copyWith(items: const [], hasMore: false)
        : state.copyWith(
            items: state.items.map((n) => n.copyWith(isRead: true)).toList(),
          );
    _onUnreadChanged();
  }
}

final notificationsControllerProvider =
    StateNotifierProvider.autoDispose<NotificationsController, NotificationsState>(
  (ref) => NotificationsController(
    ref.read(getMyNotificationsUseCaseProvider),
    ref.read(markNotificationReadUseCaseProvider),
    ref.read(markAllNotificationsReadUseCaseProvider),
    () => ref.invalidate(unreadNotificationsCountProvider),
  ),
);