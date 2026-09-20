import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/job_application_model.dart';

class ApplicationsRemoteDataSource {
  final Dio _dio;

  ApplicationsRemoteDataSource(this._dio);

  Future<JobApplicationModel> apply(String vacancyId, {String? coverMessage}) async {
    final response = await _dio.post(
      ApiConstants.applyToVacancy(vacancyId),
      data: {'coverMessage': coverMessage},
    );
    return JobApplicationModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<List<JobApplicationModel>> getMyApplications() async {
    final response = await _dio.get(ApiConstants.myApplications);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => JobApplicationModel.fromJson(json)).toList();
  }

  Future<List<JobApplicationModel>> getByVacancy(String vacancyId) async {
    final response = await _dio.get(ApiConstants.vacancyApplications(vacancyId));
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => JobApplicationModel.fromJson(json)).toList();
  }

  Future<JobApplicationModel> updateStatus(String applicationId, String status) async {
    final response = await _dio.put(
      ApiConstants.applicationStatus(applicationId),
      data: {'status': status},
    );
    return JobApplicationModel.fromJson(ApiResponse.unwrap(response.data));
  }
}