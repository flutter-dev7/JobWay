import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: context.accentColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}