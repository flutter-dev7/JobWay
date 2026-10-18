import '../../domain/entities/paged_reviews.dart';
import '../../domain/entities/review.dart';
import '../../domain/repository/reviews_repository.dart';
import '../datasources/reviews_remote_data_source.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDataSource _remoteDataSource;

  ReviewsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Review> create(String jobApplicationId, int rating, {String? comment}) async {
    final model = await _remoteDataSource.create(jobApplicationId, rating, comment: comment);
    return model.toEntity();
  }

  @override
  Future<PagedReviews> getForUser(String userId, {int pageNumber = 1, int pageSize = 10}) async {
    final model = await _remoteDataSource.getForUser(
      userId,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return model.toEntity();
  }

  @override
  Future<double> getAverageRating(String userId) => _remoteDataSource.getAverageRating(userId);
}