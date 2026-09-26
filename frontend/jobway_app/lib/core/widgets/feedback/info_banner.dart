import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class InfoBanner extends StatelessWidget {
  final String text;
  final IconData icon;

  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.shield_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 18, color: context.accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, height: 1.5, color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }
}