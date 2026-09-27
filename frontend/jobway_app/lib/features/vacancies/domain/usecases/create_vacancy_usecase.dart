import '../entities/vacancy.dart';
import '../repository/vacancies_repository.dart';

class CreateVacancyUseCase {
  final VacanciesRepository _repository;

  CreateVacancyUseCase(this._repository);

  Future<Vacancy> call({
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
  }) =>
      _repository.create(
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