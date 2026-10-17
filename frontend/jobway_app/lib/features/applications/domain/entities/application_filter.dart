class ApplicationFilter {
  final String? status;
  final String sortBy;
  final int pageNumber;
  final int pageSize;

  const ApplicationFilter({
    this.status,
    this.sortBy = 'date',
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  ApplicationFilter copyWith({
    String? status,
    String? sortBy,
    int? pageNumber,
    bool clearStatus = false,
  }) {
    return ApplicationFilter(
      status: clearStatus ? null : (status ?? this.status),
      sortBy: sortBy ?? this.sortBy,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize,
    );
  }

  Map<String, dynamic> toQueryParams() => {
    if (status != null) 'status': status,
    'sortBy': sortBy,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
  };
}