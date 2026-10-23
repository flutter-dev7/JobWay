class CompanySearchItem {
  final String id;
  final String companyName;
  final String? industry;
  final String? location;
  final String? logoUrl;
  final int activeVacanciesCount;

  const CompanySearchItem({
    required this.id,
    required this.companyName,
    this.industry,
    this.location,
    this.logoUrl,
    required this.activeVacanciesCount,
  });
}