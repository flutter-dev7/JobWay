import '../../domain/entities/paged_reviews.dart';
import 'review_model.dart';

class PagedReviewsModel {
  final List<ReviewModel> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  PagedReviewsModel({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });

  factory PagedReviewsModel.fromJson(Map<String, dynamic> json) {
    return PagedReviewsModel(
      items: (json['items'] as List)
          .map((e) => ReviewModel.fromJson(e))
          .toList(),
      pageNumber: json['pageNumber'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
    );
  }

  PagedReviews toEntity() => PagedReviews(
    items: items.map((m) => m.toEntity()).toList(),
    hasMore: pageNumber < totalPages,
    totalCount: totalCount,
  );
}