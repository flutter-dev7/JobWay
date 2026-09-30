class ChatMessage {
  final String id;
  final String jobApplicationId;
  final String senderUserId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.jobApplicationId,
    required this.senderUserId,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });
}