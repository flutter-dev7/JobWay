import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/candidate_profile_model.dart';

class CandidateProfileRemoteDataSource {
  final Dio _dio;

  CandidateProfileRemoteDataSource(this._dio);

  Future<CandidateProfileModel> getMyProfile() async {
    final response = await _dio.get(ApiConstants.candidateProfileMe);
    return CandidateProfileModel.fromJson(response.data);
  }

  Future<CandidateProfileModel> updateMyProfile({
    required String fullName,
    DateTime? birthDate,
    String? location,
    String? bio,
    String? resumeFileUrl,
    required String experienceLevel,
    required String desiredEmploymentType,
    required List<String> skillIds,
  }) async {
    final response = await _dio.put(ApiConstants.candidateProfileMe, data: {
      'fullName': fullName,
      'birthDate': birthDate?.toIso8601String().split('T').first,
      'location': location,
      'bio': bio,
      'resumeFileUrl': resumeFileUrl,
      'experienceLevel': experienceLevel,
      'desiredEmploymentType': desiredEmploymentType,
      'skillIds': skillIds,
    });
    return CandidateProfileModel.fromJson(response.data);
  }
}