import '../repository/admin_repository.dart';

class VerifyCompanyUseCase {
  final AdminRepository _repository;
  VerifyCompanyUseCase(this._repository);
  Future<void> call(String id) => _repository.verifyCompany(id);
}