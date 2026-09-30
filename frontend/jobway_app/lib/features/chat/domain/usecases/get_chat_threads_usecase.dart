import '../entities/chat_thread.dart';
import '../repository/chat_repository.dart';

class GetChatThreadsUseCase {
  final ChatRepository _repository;

  GetChatThreadsUseCase(this._repository);

  Future<List<ChatThread>> call() => _repository.getMyThreads();
}