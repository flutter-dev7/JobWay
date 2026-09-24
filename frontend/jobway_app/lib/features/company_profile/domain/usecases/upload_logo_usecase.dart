import 'dart:io';
import '../entities/company_profile.dart';
import '../repository/company_profile_repository.dart';

class UploadCompanyLogoUseCase {
  final CompanyProfileRepository _repository;
  UploadCompanyLogoUseCase(this._repository);
  Future<CompanyProfile> call(File file) => _repository.uploadLogo(file);
}