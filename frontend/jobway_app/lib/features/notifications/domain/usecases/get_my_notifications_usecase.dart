import '../entities/notification_filter.dart';
import '../entities/paged_notifications.dart';
import '../repository/notifications_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationsRepository _repository;

  GetMyNotificationsUseCase(this._repository);

  Future<PagedNotifications> call(NotificationFilter filter) =>
      _repository.getMyNotifications(filter);
}