import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
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

  Future<List<ReviewModel>> getForUser(String userId) async {
    final response = await _dio.get(ApiConstants.reviewsForUser(userId));
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => ReviewModel.fromJson(json)).toList();
  }

  Future<double> getAverageRating(String userId) async {
    final response = await _dio.get(ApiConstants.reviewAverageRating(userId));
    final data = ApiResponse.unwrap(response.data);
    return (data as num).toDouble();
  }
}