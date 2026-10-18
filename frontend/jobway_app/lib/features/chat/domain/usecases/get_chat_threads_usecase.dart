import '../entities/paged_chat_threads.dart';
import '../repository/chat_repository.dart';

class GetChatThreadsUseCase {
  final ChatRepository _repository;

  GetChatThreadsUseCase(this._repository);

  Future<PagedChatThreads> call({bool unreadOnly = false, int pageNumber = 1}) =>
      _repository.getMyThreads(unreadOnly: unreadOnly, pageNumber: pageNumber);
}