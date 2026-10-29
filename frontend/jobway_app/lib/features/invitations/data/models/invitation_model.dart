import '../../domain/entities/invitation.dart';

class InvitationModel {
  final String id;
  final String vacancyId;
  final String vacancyTitle;
  final String vacancyStatus;
  final String companyProfileId;
  final String companyUserId;
  final String companyName;
  final String? companyLogoUrl;
  final String? message;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  InvitationModel({
    required this.id,
    required this.vacancyId,
    required this.vacancyTitle,
    required this.vacancyStatus,
    required this.companyProfileId,
    required this.companyUserId,
    required this.companyName,
    this.companyLogoUrl,
    this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) => InvitationModel(
    id: json['id'],
    vacancyId: json['vacancyId'],
    vacancyTitle: json['vacancyTitle'],
    vacancyStatus: json['vacancyStatus'],
    companyProfileId: json['companyProfileId'],
    companyUserId: json['companyUserId'],
    companyName: json['companyName'],
    companyLogoUrl: json['companyLogoUrl'],
    message: json['message'],
    status: json['status'],
    createdAt: DateTime.parse(json['createdAt']),
    respondedAt: json['respondedAt'] != null
        ? DateTime.parse(json['respondedAt'])
        : null,
  );

  Invitation toEntity() => Invitation(
    id: id,
    vacancyId: vacancyId,
    vacancyTitle: vacancyTitle,
    vacancyStatus: vacancyStatus,
    companyProfileId: companyProfileId,
    companyUserId: companyUserId,
    companyName: companyName,
    companyLogoUrl: companyLogoUrl,
    message: message,
    status: status,
    createdAt: createdAt,
    respondedAt: respondedAt,
  );
}