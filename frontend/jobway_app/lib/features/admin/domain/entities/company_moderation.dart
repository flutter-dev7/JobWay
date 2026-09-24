class CompanyModeration {
  final String id;
  final String companyName;
  final String? industry;
  final String? location;
  final String? logoUrl;
  final String verificationStatus;

  const CompanyModeration({
    required this.id,
    required this.companyName,
    this.industry,
    this.location,
    this.logoUrl,
    required this.verificationStatus,
  });
}