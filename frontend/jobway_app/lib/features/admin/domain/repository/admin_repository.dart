import '../entities/admin_page.dart';
import '../entities/company_moderation.dart';
import '../entities/user_moderation.dart';

abstract class AdminRepository {
  Future<AdminPage<CompanyModeration>> getCompanies({
    String? status,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<void> verifyCompany(String id);
  Future<void> rejectCompany(String id);

  Future<AdminPage<UserModeration>> getUsers({
    String? role,
    bool? isActive,
    String? search,
    int pageNumber = 1,
    int pageSize = 20,
  });
  Future<void> blockUser(String id);
  Future<void> unblockUser(String id);
}