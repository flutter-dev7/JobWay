import '../repository/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;

  MarkNotificationReadUseCase(this._repository);

  Future<void> call(String id) => _repository.markAsRead(id);
}