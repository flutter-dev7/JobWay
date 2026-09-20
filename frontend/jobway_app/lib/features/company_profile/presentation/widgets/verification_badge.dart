import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final String status;

  const VerificationBadge({super.key, required this.status});

  Color _color() {
    switch (status) {
      case 'Verified':
        return const Color(0xFF059669);
      case 'Rejected':
        return const Color(0xFFDC2626);
      case 'Pending':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _icon() {
    switch (status) {
      case 'Verified':
        return Icons.verified_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_bottom_rounded;
    }
  }

  String _label() {
    switch (status) {
      case 'Verified':
        return 'Компания верифицирована';
      case 'Rejected':
        return 'Заявка на верификацию отклонена';
      case 'Pending':
        return 'Верификация на рассмотрении';
      default:
        return 'Компания не верифицирована';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(_icon(), size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_label(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}