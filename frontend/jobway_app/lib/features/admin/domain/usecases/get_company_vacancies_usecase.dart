import '../entities/admin_vacancy.dart';
import '../repository/admin_repository.dart';

class GetCompanyVacanciesUseCase {
  final AdminRepository _repository;
  GetCompanyVacanciesUseCase(this._repository);

  Future<List<AdminVacancy>> call(String companyId) =>
      _repository.getCompanyVacancies(companyId);
}