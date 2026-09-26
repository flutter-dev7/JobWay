import '../repository/reviews_repository.dart';

class GetAverageRatingUseCase {
  final ReviewsRepository _repository;

  GetAverageRatingUseCase(this._repository);

  Future<double> call(String userId) => _repository.getAverageRating(userId);
}