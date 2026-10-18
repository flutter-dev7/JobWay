import 'chat_message.dart';

class PagedChatMessages {
  final List<ChatMessage> items;
  final bool hasMore;

  const PagedChatMessages({required this.items, required this.hasMore});
}