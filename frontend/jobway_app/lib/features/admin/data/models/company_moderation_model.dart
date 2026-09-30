import '../../domain/entities/company_moderation.dart';

class CompanyModerationModel {
  final String id;
  final String userId;
  final String companyName;
  final String? description;
  final String? industry;
  final String? website;
  final String? location;
  final String? logoUrl;
  final String verificationStatus;

  CompanyModerationModel({
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

  factory CompanyModerationModel.fromJson(Map<String, dynamic> json) {
    return CompanyModerationModel(
      id: json['id'],
      userId: json['userId'],
      companyName: json['companyName'],
      description: json['description'],
      industry: json['industry'],
      website: json['website'],
      location: json['location'],
      logoUrl: json['logoUrl'],
      verificationStatus: json['verificationStatus'],
    );
  }

  CompanyModeration toEntity() => CompanyModeration(
        id: id,
        userId: userId,
        companyName: companyName,
        description: description,
        industry: industry,
        website: website,
        location: location,
        logoUrl: logoUrl,
        verificationStatus: verificationStatus,
      );
}