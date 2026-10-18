import '../../domain/entities/paged_chat_messages.dart';
import 'chat_message_model.dart';

class PagedChatMessagesModel {
  final List<ChatMessageModel> items;
  final bool hasMore;

  PagedChatMessagesModel({required this.items, required this.hasMore});

  factory PagedChatMessagesModel.fromJson(Map<String, dynamic> json) {
    return PagedChatMessagesModel(
      items: (json['items'] as List)
          .map((m) => ChatMessageModel.fromJson(m))
          .toList(),
      hasMore: json['hasMore'] ?? false,
    );
  }

  PagedChatMessages toEntity() => PagedChatMessages(
    items: items.map((m) => m.toEntity()).toList(),
    hasMore: hasMore,
  );
}