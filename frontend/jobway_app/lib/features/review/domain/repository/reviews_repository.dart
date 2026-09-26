import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Review> create(String jobApplicationId, int rating, {String? comment});
  Future<List<Review>> getForUser(String userId);
  Future<double> getAverageRating(String userId);
}