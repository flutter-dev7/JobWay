import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/search_page.dart';

typedef SearchFetcher<T> = Future<SearchPage<T>> Function({
  required String query,
  String? filter,
  required int pageNumber,
});

class SearchState<T> {
  final List<T> items;
  final String query;
  final String? filter;
  final int pageNumber;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const SearchState({
    this.items = const [],
    this.query = '',
    this.filter,
    this.pageNumber = 1,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  SearchState<T> copyWith({
    List<T>? items,
    String? query,
    String? filter,
    int? pageNumber,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearFilter = false,
  }) {
    return SearchState<T>(
      items: items ?? this.items,
      query: query ?? this.query,
      filter: clearFilter ? null : (filter ?? this.filter),
      pageNumber: pageNumber ?? this.pageNumber,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class SearchListController<T> extends StateNotifier<SearchState<T>> {
  final SearchFetcher<T> _fetch;
  int _requestId = 0;

  SearchListController(this._fetch) : super(SearchState<T>()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final page = await _fetch(query: state.query, filter: state.filter, pageNumber: 1);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: page.items,
        pageNumber: 1,
        totalCount: page.totalCount,
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
      final page = await _fetch(query: state.query, filter: state.filter, pageNumber: nextPage);
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        pageNumber: nextPage,
        totalCount: page.totalCount,
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void applyQuery(String query) {
    if (query == state.query) return;
    state = state.copyWith(query: query, items: const [], hasMore: true);
    load();
  }

  void applyFilter(String? filter) {
    if (filter == state.filter) return;
    state = state.copyWith(
      filter: filter,
      clearFilter: filter == null,
      items: const [],
      hasMore: true,
    );
    load();
  }
}