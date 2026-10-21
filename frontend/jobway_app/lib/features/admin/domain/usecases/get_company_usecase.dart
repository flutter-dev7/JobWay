import '../entities/company_moderation.dart';
import '../repository/admin_repository.dart';

class GetCompanyUseCase {
  final AdminRepository _repository;
  GetCompanyUseCase(this._repository);

  Future<CompanyModeration> call(String id) => _repository.getCompany(id);
}