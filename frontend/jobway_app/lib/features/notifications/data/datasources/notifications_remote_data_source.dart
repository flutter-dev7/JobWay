import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/notification_model.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSource(this._dio);

  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _dio.get(ApiConstants.myNotifications);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.put(ApiConstants.markNotificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dio.put(ApiConstants.markAllNotificationsRead);
  }
}
