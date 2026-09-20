import '../entities/company_profile.dart';
import '../repository/company_profile_repository.dart';

class GetCompanyProfileUseCase {
  final CompanyProfileRepository _repository;

  GetCompanyProfileUseCase(this._repository);

  Future<CompanyProfile> call() => _repository.getMyProfile();
}