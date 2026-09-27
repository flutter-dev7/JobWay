import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/skill.dart';

class SkillChip extends StatelessWidget {
  final Skill skill;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillChip({super.key, required this.skill, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colors.textPrimary : colors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? colors.textPrimary : colors.border),
        ),
        child: Text(
          skill.nameRu,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? colors.surface : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}