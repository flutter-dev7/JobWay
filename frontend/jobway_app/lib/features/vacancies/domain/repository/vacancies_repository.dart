import 'package:jobway_app/features/vacancies/domain/entities/my_vacancies_filter.dart';

import '../entities/vacancies_page.dart';
import '../entities/vacancy.dart';
import '../entities/vacancy_filter.dart';

abstract class VacanciesRepository {
  Future<VacanciesPage> getActive(VacancyFilter filter);
  Future<Vacancy> getById(String id);
  Future<VacanciesPage> getMyVacancies(MyVacanciesFilter filter);

  Future<Vacancy> create({
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
  });

  Future<Vacancy> update(
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
  });

  Future<int> getTodayCount();

  Future<Vacancy> publish(String id);
  Future<Vacancy> close(String id);

  Future<void> save(String vacancyId);
  Future<void> unsave(String vacancyId);
  Future<VacanciesPage> getSaved(VacancyFilter filter);
  Future<List<String>> getSavedIds();}
