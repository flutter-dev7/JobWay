import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/employer_analytics_model.dart';

class AnalyticsRemoteDataSource {
  final Dio _dio;

  AnalyticsRemoteDataSource(this._dio);

  Future<EmployerAnalyticsModel> getEmployerAnalytics() async {
    final response = await _dio.get(ApiConstants.employerAnalytics);
    return EmployerAnalyticsModel.fromJson(response.data);
  }
}