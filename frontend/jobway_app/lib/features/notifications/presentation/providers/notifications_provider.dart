import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/notifications_remote_data_source.dart';
import '../../data/repository/notifications_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repository/notifications_repository.dart';
import '../../domain/usecases/get_my_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

final notificationsRemoteDataSourceProvider = Provider(
  (ref) => NotificationsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepositoryImpl(
    ref.read(notificationsRemoteDataSourceProvider),
  ),
);

final getMyNotificationsUseCaseProvider = Provider(
  (ref) => GetMyNotificationsUseCase(ref.read(notificationsRepositoryProvider)),
);

final markNotificationReadUseCaseProvider = Provider(
  (ref) =>
      MarkNotificationReadUseCase(ref.read(notificationsRepositoryProvider)),
);

final myNotificationsProvider =
    FutureProvider.autoDispose<List<AppNotification>>(
      (ref) => ref.read(getMyNotificationsUseCaseProvider)(),
    );

final markAllNotificationsReadUseCaseProvider = Provider(
  (ref) => MarkAllNotificationsReadUseCase(
    ref.read(notificationsRepositoryProvider),
  ),
);

final unreadNotificationsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final notifications = await ref.watch(myNotificationsProvider.future);
  return notifications.where((n) => !n.isRead).length;
});
