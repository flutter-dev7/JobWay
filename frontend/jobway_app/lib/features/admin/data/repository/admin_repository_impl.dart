import 'package:jobway_app/features/admin/domain/entities/admin_vacancy.dart';

import '../../domain/entities/admin_page.dart';
import '../../domain/entities/company_moderation.dart';
import '../../domain/entities/user_moderation.dart';
import '../../domain/repository/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<AdminPage<CompanyModeration>> getCompanies({
    String? status,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getCompanies(
      status: status,
      search: search,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return AdminPage<CompanyModeration>(
      items: response.items.map((m) => m.toEntity()).toList(),
      hasMore: response.pageNumber < response.totalPages,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<void> verifyCompany(String id) => _remoteDataSource.verifyCompany(id);

  @override
  Future<void> rejectCompany(String id) => _remoteDataSource.rejectCompany(id);

  @override
  Future<AdminPage<UserModeration>> getUsers({
    String? role,
    bool? isActive,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _remoteDataSource.getUsers(
      role: role,
      isActive: isActive,
      search: search,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
    return AdminPage<UserModeration>(
      items: response.items.map((m) => m.toEntity()).toList(),
      hasMore: response.pageNumber < response.totalPages,
      totalCount: response.totalCount,
    );
  }

  @override
  Future<CompanyModeration> setCompanyTier(
    String id, {
    required String tier,
    int days = 30,
  }) async {
    final model = await _remoteDataSource.setCompanyTier(
      id,
      tier: tier,
      days: days,
    );
    return model.toEntity();
  }

  @override
  Future<List<AdminVacancy>> getCompanyVacancies(String companyId) async {
    final models = await _remoteDataSource.getCompanyVacancies(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AdminVacancy> featureVacancy(String id, {required int days}) async {
    final model = await _remoteDataSource.featureVacancy(id, days: days);
    return model.toEntity();
  }

  @override
  Future<CompanyModeration> getCompany(String id) async {
    final model = await _remoteDataSource.getCompany(id);
    return model.toEntity();
  }

  @override
  Future<void> blockUser(String id) => _remoteDataSource.blockUser(id);

  @override
  Future<void> unblockUser(String id) => _remoteDataSource.unblockUser(id);
}
