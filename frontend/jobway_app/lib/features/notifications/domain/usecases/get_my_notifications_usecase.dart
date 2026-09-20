import '../entities/notification.dart';
import '../repository/notifications_repository.dart';

class GetMyNotificationsUseCase {
  final NotificationsRepository _repository;

  GetMyNotificationsUseCase(this._repository);

  Future<List<AppNotification>> call() => _repository.getMyNotifications();
}