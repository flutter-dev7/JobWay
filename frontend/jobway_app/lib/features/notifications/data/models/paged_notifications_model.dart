import '../../domain/entities/paged_notifications.dart';
import 'notification_model.dart';

class PagedNotificationsModel {
  final List<NotificationModel> items;
  final int pageNumber;
  final int totalPages;

  PagedNotificationsModel({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
  });

  factory PagedNotificationsModel.fromJson(Map<String, dynamic> json) {
    return PagedNotificationsModel(
      items: (json['items'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      pageNumber: json['pageNumber'],
      totalPages: json['totalPages'],
    );
  }

  PagedNotifications toEntity() => PagedNotifications(
    items: items.map((m) => m.toEntity()).toList(),
    hasMore: pageNumber < totalPages,
  );
}