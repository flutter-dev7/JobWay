import '../entities/notification_filter.dart';
import '../entities/paged_notifications.dart';

abstract class NotificationsRepository {
  Future<PagedNotifications> getMyNotifications(NotificationFilter filter);
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}