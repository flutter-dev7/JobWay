import '../entities/paged_chat_messages.dart';
import '../repository/chat_repository.dart';

class GetChatMessagesUseCase {
  final ChatRepository _repository;

  GetChatMessagesUseCase(this._repository);

  Future<PagedChatMessages> call(
    String jobApplicationId, {
    DateTime? since,
    DateTime? before,
  }) => _repository.getMessages(jobApplicationId, since: since, before: before);
}