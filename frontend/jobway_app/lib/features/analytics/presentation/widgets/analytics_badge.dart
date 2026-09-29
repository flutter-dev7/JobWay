import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AnalyticsBadge extends StatelessWidget {
  final String text;

  const AnalyticsBadge(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textSecondary),
      ),
    );
  }
}