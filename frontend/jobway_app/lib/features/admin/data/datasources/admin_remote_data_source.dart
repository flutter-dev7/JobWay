import 'package:dio/dio.dart';
import 'package:jobway_app/features/admin/data/models/admin_vacancy_model.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/company_moderation_model.dart';
import '../models/user_moderation_model.dart';

class AdminPageResponse<T> {
  final List<T> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  AdminPageResponse({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });
}

class AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSource(this._dio);

  Future<AdminPageResponse<CompanyModerationModel>> getCompanies({
    String? status,
    String? search,
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminCompanies,
      queryParameters: {
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    final data = ApiResponse.unwrap(response.data);
    return AdminPageResponse<CompanyModerationModel>(
      items: (data['items'] as List)
          .map((json) => CompanyModerationModel.fromJson(json))
          .toList(),
      pageNumber: data['pageNumber'],
      totalPages: data['totalPages'],
      totalCount: data['totalCount'],
    );
  }

  Future<void> verifyCompany(String id) async {
    await _dio.put(ApiConstants.verifyCompany(id));
  }

  Future<void> rejectCompany(String id) async {
    await _dio.put(ApiConstants.rejectCompany(id));
  }

  Future<AdminPageResponse<UserModerationModel>> getUsers({
    String? role,
    bool? isActive,
    String? search,
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      ApiConstants.adminUsers,
      queryParameters: {
        if (role != null) 'role': role,
        if (isActive != null) 'isActive': isActive,
        if (search != null && search.isNotEmpty) 'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );
    final data = ApiResponse.unwrap(response.data);
    return AdminPageResponse<UserModerationModel>(
      items: (data['items'] as List)
          .map((json) => UserModerationModel.fromJson(json))
          .toList(),
      pageNumber: data['pageNumber'],
      totalPages: data['totalPages'],
      totalCount: data['totalCount'],
    );
  }

  Future<CompanyModerationModel> setCompanyTier(
    String id, {
    required String tier,
    required int days,
  }) async {
    final response = await _dio.put(
      ApiConstants.setCompanyTier(id),
      data: {'tier': tier, 'days': days},
    );
    return CompanyModerationModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<List<AdminVacancyModel>> getCompanyVacancies(String companyId) async {
    final response = await _dio.get(
      ApiConstants.adminCompanyVacancies(companyId),
    );
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => AdminVacancyModel.fromJson(json)).toList();
  }

  Future<AdminVacancyModel> featureVacancy(
    String id, {
    required int days,
  }) async {
    final response = await _dio.put(
      ApiConstants.featureVacancy(id),
      data: {'days': days},
    );
    return AdminVacancyModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<CompanyModerationModel> getCompany(String id) async {
    final response = await _dio.get(ApiConstants.adminCompanyById(id));
    return CompanyModerationModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<void> blockUser(String id) async {
    await _dio.put(ApiConstants.blockUser(id));
  }

  Future<void> unblockUser(String id) async {
    await _dio.put(ApiConstants.unblockUser(id));
  }
}
