import '../repository/admin_repository.dart';

class BlockUserUseCase {
  final AdminRepository _repository;
  BlockUserUseCase(this._repository);
  Future<void> call(String id) => _repository.blockUser(id);
}