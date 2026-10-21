import '../../domain/entities/admin_vacancy.dart';

class AdminVacancyModel {
  final String id;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? featuredUntil;

  AdminVacancyModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.featuredUntil,
  });

  factory AdminVacancyModel.fromJson(Map<String, dynamic> json) {
    return AdminVacancyModel(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      featuredUntil: json['featuredUntil'] != null
          ? DateTime.parse(json['featuredUntil'])
          : null,
    );
  }

  AdminVacancy toEntity() => AdminVacancy(
    id: id,
    title: title,
    status: status,
    createdAt: createdAt,
    featuredUntil: featuredUntil,
  );
}