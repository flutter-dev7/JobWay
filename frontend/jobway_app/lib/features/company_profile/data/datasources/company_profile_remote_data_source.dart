import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/company_profile_model.dart';

class CompanyProfileRemoteDataSource {
  final Dio _dio;

  CompanyProfileRemoteDataSource(this._dio);

  Future<CompanyProfileModel> getMyProfile() async {
    final response = await _dio.get(ApiConstants.companyProfileMe);
    return CompanyProfileModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<CompanyProfileModel> updateMyProfile({
    required String companyName,
    String? description,
    String? industry,
    String? logoUrl,
    String? website,
    String? location,
  }) async {
    final response = await _dio.put(ApiConstants.companyProfileMe, data: {
      'companyName': companyName,
      'description': description,
      'industry': industry,
      'logoUrl': logoUrl,
      'website': website,
      'location': location,
    });
    return CompanyProfileModel.fromJson(ApiResponse.unwrap(response.data));
  }
}