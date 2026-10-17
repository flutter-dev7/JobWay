import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/application_filter.dart';
import '../models/job_application_model.dart';
import '../models/paged_job_applications_model.dart';

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

  Future<PagedJobApplicationsModel> getMyApplications(ApplicationFilter filter) async {
    final response = await _dio.get(
      ApiConstants.myApplications,
      queryParameters: filter.toQueryParams(),
    );
    return PagedJobApplicationsModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<List<String>> getMyAppliedVacancyIds() async {
    final response = await _dio.get(ApiConstants.myAppliedVacancyIds);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((e) => e.toString()).toList();
  }

  Future<PagedJobApplicationsModel> getByVacancy(String vacancyId, ApplicationFilter filter) async {
    final response = await _dio.get(
      ApiConstants.vacancyApplications(vacancyId),
      queryParameters: filter.toQueryParams(),
    );
    return PagedJobApplicationsModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<JobApplicationModel> updateStatus(String applicationId, String status) async {
    final response = await _dio.put(
      ApiConstants.applicationStatus(applicationId),
      data: {'status': status},
    );
    return JobApplicationModel.fromJson(ApiResponse.unwrap(response.data));
  }
}