import '../entities/skill.dart';
import '../repository/skills_repository.dart';

class GetSkillsUseCase {
  final SkillsRepository _repository;

  GetSkillsUseCase(this._repository);

  Future<List<Skill>> call() => _repository.getAll();
}