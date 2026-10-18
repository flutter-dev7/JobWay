class AdminPage<T> {
  final List<T> items;
  final bool hasMore;
  final int totalCount;

  const AdminPage({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });
}