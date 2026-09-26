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
  Future<List<Review>> getForUser(String userId) async {
    final models = await _remoteDataSource.getForUser(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<double> getAverageRating(String userId) => _remoteDataSource.getAverageRating(userId);
}