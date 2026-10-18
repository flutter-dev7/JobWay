import 'chat_thread.dart';

class PagedChatThreads {
  final List<ChatThread> items;
  final bool hasMore;

  const PagedChatThreads({required this.items, required this.hasMore});
}