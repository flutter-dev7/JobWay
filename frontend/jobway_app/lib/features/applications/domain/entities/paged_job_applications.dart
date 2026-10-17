import 'job_application.dart';

class PagedJobApplications {
  final List<JobApplication> items;
  final bool hasMore;
  final int totalCount;

  const PagedJobApplications({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });
}