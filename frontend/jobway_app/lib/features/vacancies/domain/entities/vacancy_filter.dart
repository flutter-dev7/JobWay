// features/vacancies/domain/entities/vacancy_filter.dart — заменить целиком
class VacancyFilter {
  final String? search;
  final String? employmentType;
  final String? experienceLevel;
  final String? paymentType;
  final String? currency;
  final String? location;
  final double? salaryFrom;
  final int pageNumber;
  final int pageSize;

  const VacancyFilter({
    this.search,
    this.employmentType,
    this.experienceLevel,
    this.paymentType,
    this.currency,
    this.location,
    this.salaryFrom,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  VacancyFilter copyWith({
    String? search,
    String? employmentType,
    String? experienceLevel,
    String? paymentType,
    String? currency,
    String? location,
    double? salaryFrom,
    int? pageNumber,
    bool clearSearch = false,
    bool clearEmploymentType = false,
    bool clearExperienceLevel = false,
    bool clearPaymentType = false,
    bool clearCurrency = false,
    bool clearLocation = false,
    bool clearSalaryFrom = false,
  }) {
    return VacancyFilter(
      search: clearSearch ? null : (search ?? this.search),
      employmentType: clearEmploymentType ? null : (employmentType ?? this.employmentType),
      experienceLevel: clearExperienceLevel ? null : (experienceLevel ?? this.experienceLevel),
      paymentType: clearPaymentType ? null : (paymentType ?? this.paymentType),
      currency: clearCurrency ? null : (currency ?? this.currency),
      location: clearLocation ? null : (location ?? this.location),
      salaryFrom: clearSalaryFrom ? null : (salaryFrom ?? this.salaryFrom),
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (employmentType != null) 'employmentType': employmentType,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
      if (paymentType != null) 'paymentType': paymentType,
      if (currency != null) 'currency': currency,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (salaryFrom != null) 'salaryFrom': salaryFrom,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }
}