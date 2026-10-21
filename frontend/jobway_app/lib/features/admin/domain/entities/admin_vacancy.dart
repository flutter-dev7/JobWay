class AdminVacancy {
  final String id;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? featuredUntil;

  const AdminVacancy({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    this.featuredUntil,
  });

  bool get isFeatured =>
      featuredUntil != null && featuredUntil!.isAfter(DateTime.now());
}