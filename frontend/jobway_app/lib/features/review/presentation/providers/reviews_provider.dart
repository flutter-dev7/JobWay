import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/review/domain/entities/review.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/reviews_remote_data_source.dart';
import '../../data/repository/reviews_repository_impl.dart';
import '../../domain/repository/reviews_repository.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/get_average_rating_usecase.dart';
import '../../domain/usecases/get_reviews_for_user_usecase.dart';

final reviewsRemoteDataSourceProvider = Provider(
  (ref) => ReviewsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ReviewsRepositoryImpl(ref.read(reviewsRemoteDataSourceProvider)),
);

final createReviewUseCaseProvider = Provider(
  (ref) => CreateReviewUseCase(ref.read(reviewsRepositoryProvider)),
);

final getReviewsForUserUseCaseProvider = Provider(
  (ref) => GetReviewsForUserUseCase(ref.read(reviewsRepositoryProvider)),
);

final getAverageRatingUseCaseProvider = Provider(
  (ref) => GetAverageRatingUseCase(ref.read(reviewsRepositoryProvider)),
);

final averageRatingProvider = FutureProvider.autoDispose.family<double, String>(
  (ref, userId) => ref.read(getAverageRatingUseCaseProvider)(userId),
);

final reviewsForUserProvider = FutureProvider.autoDispose
    .family<List<Review>, String>(
      (ref, userId) => ref.read(getReviewsForUserUseCaseProvider)(userId),
    );
