import '../entities/chat_message.dart';
import '../entities/paged_chat_messages.dart';
import '../entities/paged_chat_threads.dart';

abstract class ChatRepository {
  Future<PagedChatThreads> getMyThreads({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  });

  Future<PagedChatMessages> getMessages(
    String jobApplicationId, {
    DateTime? since,
    DateTime? before,
  });

  Future<ChatMessage> sendMessage(String jobApplicationId, String text);
}