import '../entities/paged_reviews.dart';
import '../repository/reviews_repository.dart';

class GetReviewsForUserUseCase {
  final ReviewsRepository _repository;

  GetReviewsForUserUseCase(this._repository);

  Future<PagedReviews> call(String userId, {int pageNumber = 1, int pageSize = 10}) =>
      _repository.getForUser(userId, pageNumber: pageNumber, pageSize: pageSize);
}