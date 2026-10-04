import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jobway_app/core/network/api_response.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/candidate_profile_model.dart';

class CandidateProfileRemoteDataSource {
  final Dio _dio;

  CandidateProfileRemoteDataSource(this._dio);

  static final _uploadOptions = Options(
    sendTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  );

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
    final response = await _dio.put(
      ApiConstants.candidateProfileMe,
      data: {
        'fullName': fullName,
        'birthDate': birthDate?.toIso8601String().split('T').first,
        'location': location,
        'bio': bio,
        'resumeFileUrl': resumeFileUrl,
        'experienceLevel': experienceLevel,
        'desiredEmploymentType': desiredEmploymentType,
        'skillIds': skillIds,
      },
    );
    return CandidateProfileModel.fromJson(response.data);
  }

  Future<CandidateProfileModel> uploadResume(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _dio.post(
      ApiConstants.uploadResume,
      data: formData,
      options: _uploadOptions,
    );
    return CandidateProfileModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<CandidateProfileModel> uploadPhoto(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    final response = await _dio.post(
      ApiConstants.uploadCandidatePhoto,
      data: formData,
      options: _uploadOptions,
    );
    return CandidateProfileModel.fromJson(ApiResponse.unwrap(response.data));
  }

  Future<CandidateProfileModel> getById(String id) async {
    final response = await _dio.get(ApiConstants.candidateProfileById(id));
    return CandidateProfileModel.fromJson(ApiResponse.unwrap(response.data));
  }
}