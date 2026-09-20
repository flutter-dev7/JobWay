import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String? location;

  const ProfileHeader({required this.fullName, required this.location});

  @override
  Widget build(BuildContext context) {
    final firstLetter = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDCE5FF), width: 3),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3157D5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          if (location != null && location!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    location!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
