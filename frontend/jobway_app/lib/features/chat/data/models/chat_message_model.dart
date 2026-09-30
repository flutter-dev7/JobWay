import '../../../../core/network/api_response.dart';
import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String jobApplicationId;
  final String senderUserId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.jobApplicationId,
    required this.senderUserId,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return ChatMessageModel(
      id: data['id'],
      jobApplicationId: data['jobApplicationId'],
      senderUserId: data['senderUserId'],
      text: data['text'],
      isRead: data['isRead'] ?? false,
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  ChatMessage toEntity() => ChatMessage(
        id: id,
        jobApplicationId: jobApplicationId,
        senderUserId: senderUserId,
        text: text,
        isRead: isRead,
        createdAt: createdAt,
      );
}