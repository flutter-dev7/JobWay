import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class UpdateVacancyUseCase {
  final VacanciesRepository _repository;

  UpdateVacancyUseCase(this._repository);

  Future<Vacancy> call(
    String id, {
    required String title,
    required String description,
    required String employmentType,
    required String experienceLevel,
    required String paymentType,
    required String currency,
    String? location,
    double? salaryFrom,
    double? salaryTo,
    required List<String> skillIds,
  }) => _repository.update(
        id,
        title: title,
        description: description,
        employmentType: employmentType,
        experienceLevel: experienceLevel,
        paymentType: paymentType,
        currency: currency,
        location: location,
        salaryFrom: salaryFrom,
        salaryTo: salaryTo,
        skillIds: skillIds,
      );
}