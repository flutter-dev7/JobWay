import '../../../../core/network/api_response.dart';
import '../../domain/entities/notification.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return NotificationModel(
      id: data['id'],
      type: data['type'],
      title: data['title'],
      message: data['message'],
      isRead: data['isRead'],
      relatedEntityId: data['relatedEntityId'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  AppNotification toEntity() => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        isRead: isRead,
        relatedEntityId: relatedEntityId,
        createdAt: createdAt,
      );
}