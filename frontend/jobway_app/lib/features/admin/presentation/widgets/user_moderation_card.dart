// features/admin/presentation/widgets/user_moderation_card.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:jobway_app/core/constants/api_constants.dart';
import '../../domain/entities/user_moderation.dart';

class UserModerationCard extends StatelessWidget {
  final UserModeration user;
  final VoidCallback onToggle;
  final bool isUpdating;

  const UserModerationCard({
    super.key,
    required this.user,
    required this.onToggle,
    this.isUpdating = false,
  });

  Color _roleColor() {
    switch (user.role) {
      case 'Employer':
        return const Color(0xFF3157D5);
      case 'Admin':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF059669);
    }
  }

  IconData _roleIcon() {
    switch (user.role) {
      case 'Employer':
        return Icons.business_rounded;
      case 'Admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _roleLabel() {
    switch (user.role) {
      case 'Employer':
        return 'Работодатель';
      case 'Admin':
        return 'Администратор';
      default:
        return 'Кандидат';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'Admin';
    final roleColor = _roleColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      '${ApiConstants.fileBaseUrl}${user.photoUrl}',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(_roleIcon(), size: 22, color: roleColor),
                    ),
                  )
                : Icon(_roleIcon(), size: 22, color: roleColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _roleLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isAdmin)
            Switch(
              value: user.isActive,
              onChanged: isUpdating ? null : (_) => onToggle(),
              activeColor: const Color(0xFF3157D5),
              activeTrackColor: const Color(0xFFDCE5FF),
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(
                Icons.shield_outlined,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ),
        ],
      ),
    );
  }
}
