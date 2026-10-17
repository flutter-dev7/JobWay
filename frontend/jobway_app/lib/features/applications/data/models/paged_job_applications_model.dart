import '../../domain/entities/paged_job_applications.dart';
import 'job_application_model.dart';

class PagedJobApplicationsModel {
  final List<JobApplicationModel> items;
  final int pageNumber;
  final int totalPages;
  final int totalCount;

  PagedJobApplicationsModel({
    required this.items,
    required this.pageNumber,
    required this.totalPages,
    required this.totalCount,
  });

  factory PagedJobApplicationsModel.fromJson(Map<String, dynamic> json) {
    return PagedJobApplicationsModel(
      items: (json['items'] as List)
          .map((e) => JobApplicationModel.fromJson(e))
          .toList(),
      pageNumber: json['pageNumber'],
      totalPages: json['totalPages'],
      totalCount: json['totalCount'],
    );
  }

  PagedJobApplications toEntity() => PagedJobApplications(
    items: items.map((m) => m.toEntity()).toList(),
    hasMore: pageNumber < totalPages,
    totalCount: totalCount,
  );
}