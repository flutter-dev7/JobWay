import 'package:dio/dio.dart';
import 'package:jobway_app/features/company_profile/data/models/company_profile_model.dart';
import 'package:jobway_app/features/company_profile/domain/entities/company_profile.dart';
import 'package:jobway_app/features/vacancies/data/models/vacancy_model.dart';
import 'package:jobway_app/features/vacancies/domain/entities/vacancy.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/candidate_search_item.dart';
import '../../domain/entities/company_search_item.dart';
import '../../domain/entities/search_page.dart';
import '../models/search_item_models.dart';

class SearchRemoteDataSource {
  final Dio _dio;

  SearchRemoteDataSource(this._dio);

  Future<SearchPage<CompanySearchItem>> searchCompanies({
    required String query,
    required bool onlyWithVacancies,
    required int pageNumber,
  }) async {
    final response = await _dio.get(
      ApiConstants.searchCompanies,
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        if (onlyWithVacancies) 'onlyWithVacancies': true,
        'pageNumber': pageNumber,
        'pageSize': 20,
      },
    );
    final data = ApiResponse.unwrap(response.data);
    return SearchPage(
      items: (data['items'] as List)
          .map((e) => CompanySearchItemModel.fromJson(e))
          .toList(),
      hasMore: data['pageNumber'] < data['totalPages'],
      totalCount: data['totalCount'],
    );
  }

  Future<SearchPage<CandidateSearchItem>> searchCandidates({
    required String query,
    String? category,
    required int pageNumber,
  }) async {
    final response = await _dio.get(
      ApiConstants.searchCandidates,
      queryParameters: {
        if (query.isNotEmpty) 'search': query,
        if (category != null) 'category': category,
        'pageNumber': pageNumber,
        'pageSize': 20,
      },
    );
    final data = ApiResponse.unwrap(response.data);
    return SearchPage(
      items: (data['items'] as List)
          .map((e) => CandidateSearchItemModel.fromJson(e))
          .toList(),
      hasMore: data['pageNumber'] < data['totalPages'],
      totalCount: data['totalCount'],
    );
  }

  Future<CompanyProfile> getCompany(String id) async {
    final response = await _dio.get(ApiConstants.publicCompany(id));
    return CompanyProfileModel.fromJson(ApiResponse.unwrap(response.data)).toEntity();
  }

  Future<List<Vacancy>> getCompanyVacancies(String id) async {
    final response = await _dio.get(ApiConstants.publicCompanyVacancies(id));
    final list = ApiResponse.unwrap(response.data) as List;
    return list.map((v) => VacancyModel.fromJson(v).toEntity()).toList();
  }

  Future<bool> getVisibility() async {
    final response = await _dio.get(ApiConstants.candidateVisibility);
    return ApiResponse.unwrap(response.data) as bool;
  }

  Future<bool> setVisibility(bool isVisible) async {
    final response = await _dio.put(
      ApiConstants.candidateVisibility,
      data: {'isVisible': isVisible},
    );
    return ApiResponse.unwrap(response.data) as bool;
  }
}