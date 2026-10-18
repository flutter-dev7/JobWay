import '../entities/paged_reviews.dart';
import '../entities/review.dart';

abstract class ReviewsRepository {
  Future<Review> create(String jobApplicationId, int rating, {String? comment});
  Future<PagedReviews> getForUser(String userId, {int pageNumber = 1, int pageSize = 10});
  Future<double> getAverageRating(String userId);
}