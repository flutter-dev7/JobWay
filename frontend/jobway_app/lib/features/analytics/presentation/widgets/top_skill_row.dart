import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/employer_analytics.dart';

class TopSkillRow extends StatelessWidget {
  final TopSkillItem item;

  const TopSkillRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(item.nameRu, style: TextStyle(color: colors.textPrimary)),
          ),
          Text(
            '${item.count}',
            style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}