class CompanyModeration {
  final String id;
  final String companyName;
  final String? industry;
  final String? location;
  final String verificationStatus;

  const CompanyModeration({
    required this.id,
    required this.companyName,
    this.industry,
    this.location,
    required this.verificationStatus,
  });
}