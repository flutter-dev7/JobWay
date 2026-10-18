import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/notification_filter.dart';
import '../models/paged_notifications_model.dart';

class NotificationsRemoteDataSource {
  final Dio _dio;

  NotificationsRemoteDataSource(this._dio);

  Future<PagedNotificationsModel> getMyNotifications(NotificationFilter filter) async {
    final response = await _dio.get(
      ApiConstants.myNotifications,
      queryParameters: filter.toQueryParams(),
    );
    return PagedNotificationsModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiConstants.unreadNotificationsCount);
    return ApiResponse.unwrap(response.data) as int;
  }

  Future<void> markAsRead(String id) async {
    await _dio.put(ApiConstants.markNotificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _dio.put(ApiConstants.markAllNotificationsRead);
  }
}