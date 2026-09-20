import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/vacancy_model.dart';

class VacanciesPageResponse {
  final List<VacancyModel> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  VacanciesPageResponse({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });
}

class VacanciesRemoteDataSource {
  final Dio _dio;

  VacanciesRemoteDataSource(this._dio);

  Future<VacanciesPageResponse> getActive(Map<String, dynamic> queryParams) async {
    final response = await _dio.get(ApiConstants.vacancies, queryParameters: queryParams);
    final data = ApiResponse.unwrap(response.data);
    final items = (data['items'] as List).map((v) => VacancyModel.fromJson(v)).toList();

    return VacanciesPageResponse(
      items: items,
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalCount: data['totalCount'],
    );
  }

  Future<VacancyModel> getById(String id) async {
    final response = await _dio.get(ApiConstants.vacancyById(id));
    return VacancyModel.fromJson(ApiResponse.unwrap(response.data));
  }
}