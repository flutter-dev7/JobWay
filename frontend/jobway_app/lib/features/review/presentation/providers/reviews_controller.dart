import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_reviews_for_user_usecase.dart';
import 'reviews_provider.dart';

class ReviewsState {
  final List<Review> items;
  final int pageNumber;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const ReviewsState({
    this.items = const [],
    this.pageNumber = 1,
    this.totalCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ReviewsState copyWith({
    List<Review>? items,
    int? pageNumber,
    int? totalCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return ReviewsState(
      items: items ?? this.items,
      pageNumber: pageNumber ?? this.pageNumber,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ReviewsController extends StateNotifier<ReviewsState> {
  final String _userId;
  final GetReviewsForUserUseCase _getReviews;
  int _requestId = 0;

  ReviewsController(this._userId, this._getReviews) : super(const ReviewsState()) {
    load();
  }

  Future<void> load() async {
    final requestId = ++_requestId;
    state = state.copyWith(isLoading: true, isLoadingMore: false, error: null);
    try {
      final page = await _getReviews(_userId, pageNumber: 1);
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
      final page = await _getReviews(_userId, pageNumber: nextPage);
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
}

final reviewsControllerProvider = StateNotifierProvider.autoDispose
    .family<ReviewsController, ReviewsState, String>(
  (ref, userId) =>
      ReviewsController(userId, ref.read(getReviewsForUserUseCaseProvider)),
);