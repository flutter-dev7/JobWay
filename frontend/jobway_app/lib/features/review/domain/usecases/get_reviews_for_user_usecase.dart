import '../entities/review.dart';
import '../repository/reviews_repository.dart';

class GetReviewsForUserUseCase {
  final ReviewsRepository _repository;

  GetReviewsForUserUseCase(this._repository);

  Future<List<Review>> call(String userId) => _repository.getForUser(userId);
}