import '../entities/chat_message.dart';
import '../entities/chat_thread.dart';

abstract class ChatRepository {
  Future<List<ChatThread>> getMyThreads();
  Future<List<ChatMessage>> getMessages(String jobApplicationId, {DateTime? since});
  Future<ChatMessage> sendMessage(String jobApplicationId, String text);
}