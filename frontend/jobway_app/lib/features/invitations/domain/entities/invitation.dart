class Invitation {
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

  const Invitation({
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

  bool get isPending => status == 'Pending';
  bool get isVacancyOpen => vacancyStatus == 'Active';
}