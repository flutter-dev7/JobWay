class ChatThread {
  final String jobApplicationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final bool otherUserActive;
  final String vacancyTitle;
  final String lastMessageText;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ChatThread({
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
}