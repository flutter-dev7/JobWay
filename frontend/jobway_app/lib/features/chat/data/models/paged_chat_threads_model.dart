import '../../domain/entities/paged_chat_threads.dart';
import 'chat_thread_model.dart';

class PagedChatThreadsModel {
  final List<ChatThreadModel> items;
  final int pageNumber;
  final int totalPages;

  PagedChatThreadsModel({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
  });

  factory PagedChatThreadsModel.fromJson(Map<String, dynamic> json) {
    return PagedChatThreadsModel(
      items: (json['items'] as List)
          .map((t) => ChatThreadModel.fromJson(t))
          .toList(),
      pageNumber: json['pageNumber'],
      totalPages: json['totalPages'],
    );
  }

  PagedChatThreads toEntity() => PagedChatThreads(
    items: items.map((m) => m.toEntity()).toList(),
    hasMore: pageNumber < totalPages,
  );
}