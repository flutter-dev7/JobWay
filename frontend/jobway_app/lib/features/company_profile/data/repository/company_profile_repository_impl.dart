import 'dart:io';

import '../../domain/entities/company_profile.dart';
import '../../domain/repository/company_profile_repository.dart';
import '../datasources/company_profile_remote_data_source.dart';

class CompanyProfileRepositoryImpl implements CompanyProfileRepository {
  final CompanyProfileRemoteDataSource _remoteDataSource;

  CompanyProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<CompanyProfile> getMyProfile() async {
    final model = await _remoteDataSource.getMyProfile();
    return model.toEntity();
  }

  @override
  Future<CompanyProfile> updateMyProfile({
    required String companyName,
    String? description,
    String? industry,
    String? logoUrl,
    String? website,
    String? location,
  }) async {
    final model = await _remoteDataSource.updateMyProfile(
      companyName: companyName,
      description: description,
      industry: industry,
      logoUrl: logoUrl,
      website: website,
      location: location,
    );
    return model.toEntity();
  }

  @override
  Future<CompanyProfile> uploadLogo(File file) async {
    final model = await _remoteDataSource.uploadLogo(file);
    return model.toEntity();
  }
}
