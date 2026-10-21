import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/subscription_model.dart';

class SubscriptionRemoteDataSource {
  final Dio _dio;

  SubscriptionRemoteDataSource(this._dio);

  Future<SubscriptionModel> getMy() async {
    final response = await _dio.get(ApiConstants.mySubscription);
    return SubscriptionModel.fromJson(ApiResponse.unwrap(response.data));
  }
}