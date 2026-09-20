import '../../domain/entities/skill.dart';

class SkillModel {
  final String id;
  final String nameRu;
  final String nameTj;
  final String? category;

  SkillModel({required this.id, required this.nameRu, required this.nameTj, this.category});

  factory SkillModel.fromJson(Map<String, dynamic> json) => SkillModel(
        id: json['id'],
        nameRu: json['nameRu'],
        nameTj: json['nameTj'],
        category: json['category'],
      );

  Skill toEntity() => Skill(id: id, nameRu: nameRu, nameTj: nameTj, category: category);
}