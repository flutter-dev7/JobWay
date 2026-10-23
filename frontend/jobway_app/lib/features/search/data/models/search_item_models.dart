import '../../domain/entities/candidate_search_item.dart';
import '../../domain/entities/company_search_item.dart';

class CompanySearchItemModel {
  static CompanySearchItem fromJson(Map<String, dynamic> json) => CompanySearchItem(
    id: json['id'],
    companyName: json['companyName'],
    industry: json['industry'],
    location: json['location'],
    logoUrl: json['logoUrl'],
    activeVacanciesCount: json['activeVacanciesCount'] ?? 0,
  );
}

class CandidateSearchItemModel {
  static CandidateSearchItem fromJson(Map<String, dynamic> json) => CandidateSearchItem(
    id: json['id'],
    fullName: json['fullName'],
    photoUrl: json['photoUrl'],
    location: json['location'],
    experienceLevel: json['experienceLevel'],
    topSkills: ((json['topSkills'] ?? []) as List).map((e) => e.toString()).toList(),
  );
}