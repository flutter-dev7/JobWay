class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String? relatedEntityId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.relatedEntityId,
    required this.createdAt,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    message: message,
    isRead: isRead ?? this.isRead,
    relatedEntityId: relatedEntityId,
    createdAt: createdAt,
  );
}