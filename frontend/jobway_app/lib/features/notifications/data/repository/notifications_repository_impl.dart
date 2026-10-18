import '../../domain/entities/notification_filter.dart';
import '../../domain/entities/paged_notifications.dart';
import '../../domain/repository/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedNotifications> getMyNotifications(NotificationFilter filter) async {
    final model = await _remoteDataSource.getMyNotifications(filter);
    return model.toEntity();
  }

  @override
  Future<int> getUnreadCount() => _remoteDataSource.getUnreadCount();

  @override
  Future<void> markAsRead(String id) => _remoteDataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _remoteDataSource.markAllAsRead();
}