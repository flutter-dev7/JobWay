import '../entities/review.dart';
import '../repository/reviews_repository.dart';

class CreateReviewUseCase {
  final ReviewsRepository _repository;

  CreateReviewUseCase(this._repository);

  Future<Review> call(String jobApplicationId, int rating, {String? comment}) =>
      _repository.create(jobApplicationId, rating, comment: comment);
}