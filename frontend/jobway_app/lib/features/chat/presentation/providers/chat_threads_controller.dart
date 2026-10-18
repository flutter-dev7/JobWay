import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/get_chat_threads_usecase.dart';
import 'chat_provider.dart';

class ChatThreadsState {
  final List<ChatThread> items;
  final int pageNumber;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ChatThreadsState({
    this.items = const [],
    this.pageNumber = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ChatThreadsState copyWith({
    List<ChatThread>? items,
    int? pageNumber,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return ChatThreadsState(
      items: items ?? this.items,
      pageNumber: pageNumber ?? this.pageNumber,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ChatThreadsController extends StateNotifier<ChatThreadsState> {
  final GetChatThreadsUseCase _getThreads;
  final bool _unreadOnly;
  int _requestId = 0;

  ChatThreadsController(this._getThreads, this._unreadOnly)
    : super(const ChatThreadsState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final page = await _getThreads(unreadOnly: _unreadOnly, pageNumber: 1);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        pageNumber: 1,
        isLoading: false,
        hasMore: page.hasMore,
      );
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        isLoading: false,
        error: ApiException.extractMessage(error),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.pageNumber + 1;
      final page = await _getThreads(unreadOnly: _unreadOnly, pageNumber: nextPage);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        pageNumber: nextPage,
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

// Смена фильтра пересоздаёт контроллер, поэтому список сам загружается заново
final chatThreadsControllerProvider =
    StateNotifierProvider.autoDispose<ChatThreadsController, ChatThreadsState>((ref) {
  final unreadOnly = ref.watch(chatUnreadOnlyProvider);
  return ChatThreadsController(ref.read(getChatThreadsUseCaseProvider), unreadOnly);
});