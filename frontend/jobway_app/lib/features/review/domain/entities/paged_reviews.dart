import 'review.dart';

class PagedReviews {
  final List<Review> items;
  final bool hasMore;
  final int totalCount;

  const PagedReviews({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });
}