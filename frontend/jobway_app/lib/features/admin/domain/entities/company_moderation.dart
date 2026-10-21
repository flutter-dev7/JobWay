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
  final String tier;
  final DateTime? tierExpiresAt;

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
    this.tier = 'Free',
    this.tierExpiresAt,
  });

  bool get isPro => tier == 'Pro';

  CompanyModeration copyWith({String? verificationStatus}) => CompanyModeration(
    id: id,
    userId: userId,
    companyName: companyName,
    description: description,
    industry: industry,
    website: website,
    location: location,
    logoUrl: logoUrl,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    tier: tier,
    tierExpiresAt: tierExpiresAt,
  );
}