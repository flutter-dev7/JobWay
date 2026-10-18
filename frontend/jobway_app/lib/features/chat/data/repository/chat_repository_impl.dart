import '../../domain/entities/chat_message.dart';
import '../../domain/entities/paged_chat_messages.dart';
import '../../domain/entities/paged_chat_threads.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<PagedChatThreads> getMyThreads({
    bool unreadOnly = false,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final model = await _remoteDataSource.getMyThreads(
      unreadOnly: unreadOnly,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return model.toEntity();
  }

  @override
  Future<PagedChatMessages> getMessages(
    String jobApplicationId, {
    DateTime? since,
    DateTime? before,
  }) async {
    final model = await _remoteDataSource.getMessages(
      jobApplicationId,
      since: since,
      before: before,
    );
    return model.toEntity();
  }

  @override
  Future<ChatMessage> sendMessage(String jobApplicationId, String text) async {
    final model = await _remoteDataSource.sendMessage(jobApplicationId, text);
    return model.toEntity();
  }
}