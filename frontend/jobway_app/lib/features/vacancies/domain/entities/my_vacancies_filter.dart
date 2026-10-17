class MyVacanciesFilter {
  final String? status;
  final int pageNumber;
  final int pageSize;

  const MyVacanciesFilter({
    this.status,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  MyVacanciesFilter copyWith({
    String? status,
    int? pageNumber,
    bool clearStatus = false,
  }) {
    return MyVacanciesFilter(
      status: clearStatus ? null : (status ?? this.status),
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize,
    );
  }

  Map<String, dynamic> toQueryParams() => {
    if (status != null) 'status': status,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
  };
}