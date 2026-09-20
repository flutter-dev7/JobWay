import 'vacancy.dart';

class VacanciesPage {
  final List<Vacancy> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  const VacanciesPage({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  bool get hasMore => pageNumber * pageSize < totalCount;
}