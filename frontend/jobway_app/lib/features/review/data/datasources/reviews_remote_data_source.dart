import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/paged_reviews_model.dart';
import '../models/review_model.dart';

class ReviewsRemoteDataSource {
  final Dio _dio;

  ReviewsRemoteDataSource(this._dio);

  Future<ReviewModel> create(String jobApplicationId, int rating, {String? comment}) async {
    final response = await _dio.post(
      ApiConstants.reviewCreate,
      data: {
        'jobApplicationId': jobApplicationId,
        'rating': rating,
        'comment': comment,
      },
    );
    return ReviewModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<PagedReviewsModel> getForUser(
    String userId, {
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      ApiConstants.reviewsForUser(userId),
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    return PagedReviewsModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<double> getAverageRating(String userId) async {
    final response = await _dio.get(ApiConstants.reviewAverageRating(userId));
    final data = ApiResponse.unwrap(response.data);
    return (data as num).toDouble();
  }
}