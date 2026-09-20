import '../entities/company_moderation.dart';
import '../repository/admin_repository.dart';

class GetCompaniesUseCase {
  final AdminRepository _repository;
  GetCompaniesUseCase(this._repository);
  Future<List<CompanyModeration>> call() => _repository.getCompanies();
}