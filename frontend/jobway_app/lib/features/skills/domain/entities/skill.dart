class Skill {
  final String id;
  final String nameRu;
  final String nameTj;
  final String? category;

  const Skill({
    required this.id,
    required this.nameRu,
    required this.nameTj,
    this.category,
  });
}