import '../../domain/entities/company_moderation.dart';

class CompanyModerationModel {
  final String id;
  final String companyName;
  final String? industry;
  final String? location;
  final String? logoUrl;
  final String verificationStatus;

  CompanyModerationModel({
    required this.id,
    required this.companyName,
    this.industry,
    this.location,
    this.logoUrl,
    required this.verificationStatus,
  });

  factory CompanyModerationModel.fromJson(Map<String, dynamic> json) {
    return CompanyModerationModel(
      id: json['id'],
      companyName: json['companyName'],
      industry: json['industry'],
      location: json['location'],
      logoUrl: json['logoUrl'],
      verificationStatus: json['verificationStatus'],
    );
  }

  CompanyModeration toEntity() => CompanyModeration(
        id: id,
        companyName: companyName,
        industry: industry,
        location: location,
        logoUrl: logoUrl,
        verificationStatus: verificationStatus,
      );
}