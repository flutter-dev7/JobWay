class Review {
  final String id;
  final String type;
  final String reviewerUserId;
  final String revieweeUserId;
  final String reviewerName;
  final String? reviewerPhotoUrl;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.type,
    required this.reviewerUserId,
    required this.revieweeUserId,
    required this.reviewerName,
    this.reviewerPhotoUrl,
    required this.rating,
    this.comment,
    required this.createdAt,
  });
}
