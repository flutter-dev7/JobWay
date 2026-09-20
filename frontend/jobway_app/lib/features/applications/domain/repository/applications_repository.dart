import '../entities/job_application.dart';

abstract class ApplicationsRepository {
  Future<JobApplication> apply(String vacancyId, {String? coverMessage});
  Future<List<JobApplication>> getMyApplications();
  Future<List<JobApplication>> getByVacancy(String vacancyId);
  Future<JobApplication> updateStatus(String applicationId, String status);
}