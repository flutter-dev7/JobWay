import '../repository/admin_repository.dart';

class UnblockUserUseCase {
  final AdminRepository _repository;
  UnblockUserUseCase(this._repository);
  Future<void> call(String id) => _repository.unblockUser(id);
}