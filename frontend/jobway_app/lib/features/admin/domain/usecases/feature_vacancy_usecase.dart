import '../entities/admin_vacancy.dart';
import '../repository/admin_repository.dart';

class FeatureVacancyUseCase {
  final AdminRepository _repository;
  FeatureVacancyUseCase(this._repository);

  // days = 0 снимает продвижение
  Future<AdminVacancy> call(String id, {required int days}) =>
      _repository.featureVacancy(id, days: days);
}