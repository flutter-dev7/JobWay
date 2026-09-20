import '../../domain/entities/company_moderation.dart';
import '../../domain/entities/user_moderation.dart';
import '../../domain/repository/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CompanyModeration>> getCompanies() async {
    final models = await _remoteDataSource.getCompanies();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> verifyCompany(String id) => _remoteDataSource.verifyCompany(id);

  @override
  Future<void> rejectCompany(String id) => _remoteDataSource.rejectCompany(id);

  @override
  Future<List<UserModeration>> getUsers() async {
    final models = await _remoteDataSource.getUsers();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> blockUser(String id) => _remoteDataSource.blockUser(id);

  @override
  Future<void> unblockUser(String id) => _remoteDataSource.unblockUser(id);
}