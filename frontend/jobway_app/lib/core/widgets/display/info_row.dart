import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (icon == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: colors.textMuted)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? colors.textPrimary),
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: colors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 19, color: colors.textSecondary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: colors.textMuted)),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: valueColor ?? colors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoOverviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoOverviewRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? colors.textPrimary),
        ),
      ],
    );
  }
}