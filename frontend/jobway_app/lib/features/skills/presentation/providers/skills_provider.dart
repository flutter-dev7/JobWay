import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/skills_remote_data_source.dart';
import '../../data/repository/skills_repository_impl.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repository/skills_repository.dart';
import '../../domain/usecases/get_skills_usecase.dart';

final skillsRemoteDataSourceProvider = Provider(
  (ref) => SkillsRemoteDataSource(ref.read(dioClientProvider).dio),
);

final skillsRepositoryProvider = Provider<SkillsRepository>(
  (ref) => SkillsRepositoryImpl(ref.read(skillsRemoteDataSourceProvider)),
);

final getSkillsUseCaseProvider = Provider((ref) => GetSkillsUseCase(ref.read(skillsRepositoryProvider)));

final skillsListProvider = FutureProvider<List<Skill>>((ref) => ref.read(getSkillsUseCaseProvider)());