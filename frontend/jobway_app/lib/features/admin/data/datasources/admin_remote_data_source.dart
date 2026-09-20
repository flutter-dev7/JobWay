import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/company_moderation_model.dart';
import '../models/user_moderation_model.dart';

class AdminRemoteDataSource {
  final Dio _dio;

  AdminRemoteDataSource(this._dio);

  Future<List<CompanyModerationModel>> getCompanies() async {
    final response = await _dio.get(ApiConstants.adminCompanies);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => CompanyModerationModel.fromJson(json)).toList();
  }

  Future<void> verifyCompany(String id) async {
    await _dio.put(ApiConstants.verifyCompany(id));
  }

  Future<void> rejectCompany(String id) async {
    await _dio.put(ApiConstants.rejectCompany(id));
  }

  Future<List<UserModerationModel>> getUsers() async {
    final response = await _dio.get(ApiConstants.adminUsers);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => UserModerationModel.fromJson(json)).toList();
  }

  Future<void> blockUser(String id) async {
    await _dio.put(ApiConstants.blockUser(id));
  }

  Future<void> unblockUser(String id) async {
    await _dio.put(ApiConstants.unblockUser(id));
  }
}