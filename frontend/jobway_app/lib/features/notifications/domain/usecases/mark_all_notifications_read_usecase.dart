import '../repository/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository _repository;

  MarkAllNotificationsReadUseCase(this._repository);

  Future<void> call() => _repository.markAllAsRead();
}