import '../entities/admin_page.dart';
import '../entities/user_moderation.dart';
import '../repository/admin_repository.dart';

class GetUsersUseCase {
  final AdminRepository _repository;
  GetUsersUseCase(this._repository);

  Future<AdminPage<UserModeration>> call({
    String? role,
    bool? isActive,
    String? search,
    int pageNumber = 1,
  }) => _repository.getUsers(
    role: role,
    isActive: isActive,
    search: search,
    pageNumber: pageNumber,
  );
}