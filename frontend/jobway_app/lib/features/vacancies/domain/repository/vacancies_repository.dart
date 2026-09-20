import '../entities/vacancies_page.dart';
import '../entities/vacancy.dart';
import '../entities/vacancy_filter.dart';

abstract class VacanciesRepository {
  Future<VacanciesPage> getActive(VacancyFilter filter);
  Future<Vacancy> getById(String id);
}