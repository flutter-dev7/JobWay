import '../repository/admin_repository.dart';

class RejectCompanyUseCase {
  final AdminRepository _repository;
  RejectCompanyUseCase(this._repository);
  Future<void> call(String id) => _repository.rejectCompany(id);
}