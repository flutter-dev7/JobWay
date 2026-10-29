class CompanyProfile {
  final String id;
  final String userId;
  final String companyName;
  final String? description;
  final String? industry;
  final String? logoUrl;
  final String? website;
  final String? location;
  final String? phone;
  final String? telegramUsername;
  final String verificationStatus;

  const CompanyProfile({
    required this.id,
    required this.userId,
    required this.companyName,
    this.description,
    this.industry,
    this.logoUrl,
    this.website,
    this.location,
    this.phone,
    this.telegramUsername,
    required this.verificationStatus,
  });

  bool get hasContacts =>
      (phone != null && phone!.isNotEmpty) ||
      (telegramUsername != null && telegramUsername!.isNotEmpty);
}