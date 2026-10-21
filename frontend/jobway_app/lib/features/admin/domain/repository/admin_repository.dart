import 'package:jobway_app/features/admin/domain/entities/admin_vacancy.dart';

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

  Future<CompanyModeration> setCompanyTier(
    String id, {
    required String tier,
    int days = 30,
  });

  Future<CompanyModeration> getCompany(String id);

  Future<List<AdminVacancy>> getCompanyVacancies(String companyId);
  Future<AdminVacancy> featureVacancy(String id, {required int days});

  Future<void> blockUser(String id);
  Future<void> unblockUser(String id);
}
