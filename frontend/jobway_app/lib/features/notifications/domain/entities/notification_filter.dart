class NotificationFilter {
  final List<String>? types;
  final bool unreadOnly;
  final int pageNumber;
  final int pageSize;

  const NotificationFilter({
    this.types,
    this.unreadOnly = false,
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  NotificationFilter copyWith({int? pageNumber}) => NotificationFilter(
    types: types,
    unreadOnly: unreadOnly,
    pageNumber: pageNumber ?? this.pageNumber,
    pageSize: pageSize,
  );

  Map<String, dynamic> toQueryParams() => {
    if (types != null && types!.isNotEmpty) 'types': types,
    if (unreadOnly) 'unreadOnly': true,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
  };
}