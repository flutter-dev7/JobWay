import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/repository/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ChatThread>> getMyThreads() async {
    final models = await _remoteDataSource.getMyThreads();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ChatMessage>> getMessages(String jobApplicationId, {DateTime? since}) async {
    final models = await _remoteDataSource.getMessages(jobApplicationId, since: since);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ChatMessage> sendMessage(String jobApplicationId, String text) async {
    final model = await _remoteDataSource.sendMessage(jobApplicationId, text);
    return model.toEntity();
  }
}