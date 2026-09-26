import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSecondary),
      ),
    );
  }
}