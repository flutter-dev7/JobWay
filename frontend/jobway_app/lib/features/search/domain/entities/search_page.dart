class SearchPage<T> {
  final List<T> items;
  final bool hasMore;
  final int totalCount;

  const SearchPage({
    required this.items,
    required this.hasMore,
    required this.totalCount,
  });
}