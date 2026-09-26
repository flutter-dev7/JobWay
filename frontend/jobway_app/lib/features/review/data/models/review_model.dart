import '../../../../core/network/api_response.dart';
import '../../domain/entities/review.dart';

class ReviewModel {
  final String id;
  final String type;
  final String reviewerUserId;
  final String revieweeUserId;
  final int rating;
  final String reviewerName;
  final String? reviewerPhotoUrl;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.type,
    required this.reviewerUserId,
    required this.revieweeUserId,
    required this.rating,
    required this.reviewerName,
    this.reviewerPhotoUrl,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return ReviewModel(
      id: data['id'],
      type: data['type'],
      reviewerUserId: data['reviewerUserId'],
      revieweeUserId: data['revieweeUserId'],
      rating: data['rating'],
      reviewerName: data['reviewerName'],
      reviewerPhotoUrl: data['reviewerPhotoUrl'],
      comment: data['comment'],
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  Review toEntity() => Review(
    id: id,
    type: type,
    reviewerUserId: reviewerUserId,
    revieweeUserId: revieweeUserId,
    reviewerName: reviewerName,
    reviewerPhotoUrl: reviewerPhotoUrl,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
  );
}
