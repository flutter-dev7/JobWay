import '../../domain/entities/skill.dart';
import '../../domain/repository/skills_repository.dart';
import '../datasources/skills_remote_data_source.dart';

class SkillsRepositoryImpl implements SkillsRepository {
  final SkillsRemoteDataSource _remoteDataSource;

  SkillsRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Skill>> getAll() async {
    final models = await _remoteDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }
}