import '../entities/company_moderation.dart';
import '../entities/user_moderation.dart';

abstract class AdminRepository {
  Future<List<CompanyModeration>> getCompanies();
  Future<void> verifyCompany(String id);
  Future<void> rejectCompany(String id);

  Future<List<UserModeration>> getUsers();
  Future<void> blockUser(String id);
  Future<void> unblockUser(String id);
}