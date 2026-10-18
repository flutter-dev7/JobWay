import '../entities/admin_page.dart';
import '../entities/company_moderation.dart';
import '../repository/admin_repository.dart';

class GetCompaniesUseCase {
  final AdminRepository _repository;
  GetCompaniesUseCase(this._repository);

  Future<AdminPage<CompanyModeration>> call({
    String? status,
    String? search,
    int pageNumber = 1,
  }) => _repository.getCompanies(
    status: status,
    search: search,
    pageNumber: pageNumber,
  );
}