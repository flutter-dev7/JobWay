class CompanyModeration {
  final String id;
  final String userId;
  final String companyName;
  final String? description;
  final String? industry;
  final String? website;
  final String? location;
  final String? logoUrl;
  final String verificationStatus;

  const CompanyModeration({
    required this.id,
    required this.userId,
    required this.companyName,
    this.description,
    this.industry,
    this.website,
    this.location,
    this.logoUrl,
    required this.verificationStatus,
  });
}