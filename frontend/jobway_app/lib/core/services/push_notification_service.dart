import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class PushNotificationService {
  final Dio _dio;

  PushNotificationService(this._dio);

  Future<void> registerToken() async {
    if (kIsWeb) {
      return;
    }

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();

    if (token == null) return;

    await _dio.post(
      ApiConstants.registerDeviceToken,
      data: {
        'token': token,
        'platform': 'android',
      },
    );
  }

  Future<void> unregisterToken() async {
    if (kIsWeb) return;
    await FirebaseMessaging.instance.deleteToken();
  }
}