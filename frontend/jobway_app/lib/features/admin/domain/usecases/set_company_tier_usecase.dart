import '../entities/company_moderation.dart';
import '../repository/admin_repository.dart';

class SetCompanyTierUseCase {
  final AdminRepository _repository;
  SetCompanyTierUseCase(this._repository);

  Future<CompanyModeration> call(String id, {required String tier, int days = 30}) =>
      _repository.setCompanyTier(id, tier: tier, days: days);
}