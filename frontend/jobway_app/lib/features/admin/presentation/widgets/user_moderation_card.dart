import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'Admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFFF3F5FF), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFF3157D5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(user.role, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          if (!isAdmin)
            Switch(
              value: user.isActive,
              onChanged: isUpdating ? null : (_) => onToggle(),
              activeColor: const Color(0xFF059669),
            )
          else
            const Text('Admin', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}