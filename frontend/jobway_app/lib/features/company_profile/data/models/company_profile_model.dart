import '../../../../core/network/api_response.dart';
import '../../domain/entities/company_profile.dart';

class CompanyProfileModel {
  final String id;
  final String companyName;
  final String? description;
  final String? industry;
  final String? logoUrl;
  final String? website;
  final String? location;
  final String verificationStatus;

  CompanyProfileModel({
    required this.id,
    required this.companyName,
    this.description,
    this.industry,
    this.logoUrl,
    this.website,
    this.location,
    required this.verificationStatus,
  });

  factory CompanyProfileModel.fromJson(Map<String, dynamic> json) {
    final data = ApiResponse.unwrap(json);
    return CompanyProfileModel(
      id: data['id'],
      companyName: data['companyName'],
      description: data['description'],
      industry: data['industry'],
      logoUrl: data['logoUrl'],
      website: data['website'],
      location: data['location'],
      verificationStatus: data['verificationStatus'],
    );
  }

  CompanyProfile toEntity() => CompanyProfile(
        id: id,
        companyName: companyName,
        description: description,
        industry: industry,
        logoUrl: logoUrl,
        website: website,
        location: location,
        verificationStatus: verificationStatus,
      );
}