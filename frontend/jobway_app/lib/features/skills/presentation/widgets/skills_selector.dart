import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/skills_provider.dart';
import 'skill_chip.dart';

class SkillsSelector extends ConsumerWidget {
  final List<String> selectedSkillIds;
  final ValueChanged<List<String>> onChanged;

  const SkillsSelector({super.key, required this.selectedSkillIds, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsListProvider);

    return skillsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Не удалось загрузить навыки', style: TextStyle(color: Colors.red.shade400)),
      data: (skills) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            final isSelected = selectedSkillIds.contains(skill.id);
            return SkillChip(
              skill: skill,
              isSelected: isSelected,
              onTap: () {
                final updated = List<String>.from(selectedSkillIds);
                if (isSelected) {
                  updated.remove(skill.id);
                } else {
                  updated.add(skill.id);
                }
                onChanged(updated);
              },
            );
          }).toList(),
        );
      },
    );
  }
}