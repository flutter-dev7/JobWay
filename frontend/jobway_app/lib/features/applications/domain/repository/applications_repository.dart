import '../entities/job_application.dart';

abstract class ApplicationsRepository {
  Future<JobApplication> apply(String vacancyId, {String? coverMessage});
  Future<List<JobApplication>> getMyApplications();
}