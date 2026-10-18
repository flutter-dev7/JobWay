import 'notification.dart';

class PagedNotifications {
  final List<AppNotification> items;
  final bool hasMore;

  const PagedNotifications({required this.items, required this.hasMore});
}