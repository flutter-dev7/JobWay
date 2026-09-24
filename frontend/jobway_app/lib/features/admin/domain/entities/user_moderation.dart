class UserModeration {
  final String id;
  final String email;
  final String role;
  final bool isActive;
  final String? photoUrl;

  const UserModeration({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    this.photoUrl,
  });
}