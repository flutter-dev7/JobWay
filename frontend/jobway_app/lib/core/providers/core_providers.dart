import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/services/push_notification_service.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioClientProvider = Provider((ref) => DioClient(ref.read(tokenStorageProvider)));

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    ref.read(dioClientProvider).dio,
  );
});