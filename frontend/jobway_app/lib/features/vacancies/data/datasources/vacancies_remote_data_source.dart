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

  Future<List<VacancyModel>> getMyVacancies() async {
    final response = await _dio.get(ApiConstants.myVacancies);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((v) => VacancyModel.fromJson(v)).toList();
  }

  Future<VacancyModel> create({
    required String title,
    required String description,
    required String employmentType,
    required String experienceLevel,
    String? location,
    double? salaryFrom,
    double? salaryTo,
    required List<String> skillIds,
  }) async {
    final response = await _dio.post(ApiConstants.vacancies, data: {
      'title': title,
      'description': description,
      'employmentType': employmentType,
      'experienceLevel': experienceLevel,
      'location': location,
      'salaryFrom': salaryFrom,
      'salaryTo': salaryTo,
      'skillIds': skillIds,
    });
    return VacancyModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<VacancyModel> publish(String id) async {
    final response = await _dio.post(ApiConstants.publishVacancy(id));
    return VacancyModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<VacancyModel> close(String id) async {
    final response = await _dio.post(ApiConstants.closeVacancy(id));
    return VacancyModel.fromJson(ApiResponse.unwrap(response.data));
  }
}