import '../entities/notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getMyNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}