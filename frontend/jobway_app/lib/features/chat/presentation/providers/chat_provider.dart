import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repository/chat_repository_impl.dart';
import '../../domain/repository/chat_repository.dart';
import '../../domain/usecases/get_chat_messages_usecase.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

final chatRemoteDataSourceProvider = Provider(
  (ref) => ChatRemoteDataSource(ref.read(dioClientProvider).dio),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepositoryImpl(ref.read(chatRemoteDataSourceProvider)),
);

final getChatThreadsUseCaseProvider = Provider(
  (ref) => GetChatThreadsUseCase(ref.read(chatRepositoryProvider)),
);

final getChatMessagesUseCaseProvider = Provider(
  (ref) => GetChatMessagesUseCase(ref.read(chatRepositoryProvider)),
);

final sendMessageUseCaseProvider = Provider(
  (ref) => SendMessageUseCase(ref.read(chatRepositoryProvider)),
);

// Выбранный фильтр списка бесед. Вынесен отдельно, чтобы он сохранялся,
// когда список перезагружается (например, после отправки сообщения)
final chatUnreadOnlyProvider = StateProvider<bool>((ref) => false);