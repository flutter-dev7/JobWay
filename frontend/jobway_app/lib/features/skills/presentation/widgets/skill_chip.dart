import 'package:flutter/material.dart';
import '../../domain/entities/skill.dart';

class SkillChip extends StatelessWidget {
  final Skill skill;
  final bool isSelected;
  final VoidCallback onTap;

  const SkillChip({super.key, required this.skill, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF111827) : const Color(0xFFE5E7EB)),
        ),
        child: Text(
          skill.nameRu,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}