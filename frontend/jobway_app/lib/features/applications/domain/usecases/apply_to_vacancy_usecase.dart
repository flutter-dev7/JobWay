import '../entities/job_application.dart';
import '../repository/applications_repository.dart';

class ApplyToVacancyUseCase {
  final ApplicationsRepository _repository;

  ApplyToVacancyUseCase(this._repository);

  Future<JobApplication> call(String vacancyId, {String? coverMessage}) =>
      _repository.apply(vacancyId, coverMessage: coverMessage);
}