import '../entities/company_profile.dart';
import '../repository/company_profile_repository.dart';

class UpdateCompanyProfileUseCase {
  final CompanyProfileRepository _repository;

  UpdateCompanyProfileUseCase(this._repository);

  Future<CompanyProfile> call({
    required String companyName,
    String? description,
    String? industry,
    String? logoUrl,
    String? website,
    String? location,
  }) =>
      _repository.updateMyProfile(
        companyName: companyName,
        description: description,
        industry: industry,
        logoUrl: logoUrl,
        website: website,
        location: location,
      );
}