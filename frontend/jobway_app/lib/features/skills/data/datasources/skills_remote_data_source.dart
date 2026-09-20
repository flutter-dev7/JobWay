import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../models/skill_model.dart';

class SkillsRemoteDataSource {
  final Dio _dio;

  SkillsRemoteDataSource(this._dio);

  Future<List<SkillModel>> getAll() async {
    final response = await _dio.get(ApiConstants.skills);
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((json) => SkillModel.fromJson(json)).toList();
  }
}