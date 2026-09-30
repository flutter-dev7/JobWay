import '../entities/chat_message.dart';
import '../repository/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<ChatMessage> call(String jobApplicationId, String text) =>
      _repository.sendMessage(jobApplicationId, text);
}