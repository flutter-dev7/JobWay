import '../repository/notifications_repository.dart';

class GetUnreadNotificationsCountUseCase {
  final NotificationsRepository _repository;

  GetUnreadNotificationsCountUseCase(this._repository);

  Future<int> call() => _repository.getUnreadCount();
}