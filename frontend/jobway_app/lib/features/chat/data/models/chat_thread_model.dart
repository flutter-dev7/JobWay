import '../../../../core/network/api_response.dart';
import '../../domain/entities/chat_thread.dart';

class ChatThreadModel {
  final String jobApplicationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final bool otherUserActive;
  final String vacancyTitle;
  final String lastMessageText;
  final DateTime lastMessageAt;
  final int unreadCount;

  ChatThreadModel({
    required this.jobApplicationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    required this.otherUserActive,
    required this.vacancyTitle,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatThreadModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return ChatThreadModel(
      jobApplicationId: data['jobApplicationId'],
      otherUserId: data['otherUserId'],
      otherUserName: data['otherUserName'],
      otherUserPhotoUrl: data['otherUserPhotoUrl'],
      otherUserActive: data['otherUserActive'] ?? true,
      vacancyTitle: data['vacancyTitle'],
      lastMessageText: data['lastMessageText'],
      lastMessageAt: DateTime.parse(data['lastMessageAt']),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  ChatThread toEntity() => ChatThread(
        jobApplicationId: jobApplicationId,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserPhotoUrl: otherUserPhotoUrl,
        otherUserActive: otherUserActive,
        vacancyTitle: vacancyTitle,
        lastMessageText: lastMessageText,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
      );
}