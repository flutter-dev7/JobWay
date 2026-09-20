import '../../domain/entities/user_moderation.dart';

class UserModerationModel {
  final String id;
  final String email;
  final String role;
  final bool isActive;

  UserModerationModel({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory UserModerationModel.fromJson(Map<String, dynamic> json) {
    return UserModerationModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      isActive: json['isActive'],
    );
  }

  UserModeration toEntity() => UserModeration(id: id, email: email, role: role, isActive: isActive);
}