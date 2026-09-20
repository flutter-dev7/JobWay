import '../entities/skill.dart';

abstract class SkillsRepository {
  Future<List<Skill>> getAll();
}