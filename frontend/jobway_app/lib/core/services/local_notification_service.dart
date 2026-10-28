import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/network/dio_client.dart';
import 'package:jobway_app/core/router/app_routes.dart';

class LocalNotificationService {
  LocalNotificationService._();

  // Звук и важность канала Android фиксируются при его создании,
  // поэтому при смене настроек канала нужен новый id
  static const _channelId = 'jobway_messages';
  static const _channelName = 'Уведомления JobWay';
  static const _channelDescription = 'Сообщения, отклики и статусы вакансий';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static int _nextId = 0;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    ),
  );

  static Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) {
        final context = rootNavigatorKey.currentContext;
        if (context != null) GoRouter.of(context).push(AppRoutes.notifications);
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: true,
          ),
        );
  }

  // Показывает баннер со звуком, когда push пришёл при открытом приложении
  static Future<void> showFromMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _plugin.show(
      id: _nextId++,
      title: notification.title,
      body: notification.body,
      notificationDetails: _details,
    );
  }
}