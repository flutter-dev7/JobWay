import '../entities/chat_message.dart';
import '../repository/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  Future<List<ChatMessage>> call(String jobApplicationId, {DateTime? since}) =>
      _repository.getMessages(jobApplicationId, since: since);
}