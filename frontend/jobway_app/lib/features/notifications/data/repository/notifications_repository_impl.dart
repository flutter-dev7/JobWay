import '../../domain/entities/notification.dart';
import '../../domain/repository/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<AppNotification>> getMyNotifications() async {
    final models = await _remoteDataSource.getMyNotifications();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String id) => _remoteDataSource.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _remoteDataSource.markAllAsRead();
}