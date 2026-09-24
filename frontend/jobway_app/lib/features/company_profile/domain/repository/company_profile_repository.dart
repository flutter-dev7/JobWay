import 'dart:io';

import '../entities/company_profile.dart';

abstract class CompanyProfileRepository {
  Future<CompanyProfile> getMyProfile();

  Future<CompanyProfile> updateMyProfile({
    required String companyName,
    String? description,
    String? industry,
    String? logoUrl,
    String? website,
    String? location,
  });

  Future<CompanyProfile> uploadLogo(File file);
}