import '../entities/user_moderation.dart';
import '../repository/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository _repository;
  GetUsersUseCase(this._repository);
  Future<List<UserModeration>> call() => _repository.getUsers();
}