class CompanyProfile {
  final String id;
  final String userId;
  final String companyName;
  final String? description;
  final String? industry;
  final String? logoUrl;
  final String? website;
  final String? location;
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
    required this.verificationStatus,
  });
}