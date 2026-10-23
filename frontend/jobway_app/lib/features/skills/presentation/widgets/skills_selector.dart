import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/skills/domain/skill_categories.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/entities/skill.dart';
import '../providers/skills_provider.dart';
import 'skill_chip.dart';

class SkillsSelector extends ConsumerStatefulWidget {
  final List<String> selectedSkillIds;
  final ValueChanged<List<String>> onChanged;

  const SkillsSelector({
    super.key,
    required this.selectedSkillIds,
    required this.onChanged,
  });

  @override
  ConsumerState<SkillsSelector> createState() => _SkillsSelectorState();
}

class _SkillsSelectorState extends ConsumerState<SkillsSelector> {
  static const _otherGroup = 'Другое';
    static const _order = skillCategories;

  final _searchController = TextEditingController();
  final _expanded = <String>{};
  bool _expandedInitialized = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggle(Skill skill) {
    final updated = List<String>.from(widget.selectedSkillIds);
    if (!updated.remove(skill.id)) updated.add(skill.id);
    widget.onChanged(updated);
  }

  String _groupOf(Skill skill) {
    final category = skill.category?.trim();
    return category == null || category.isEmpty ? _otherGroup : category;
  }

  Map<String, List<Skill>> _group(List<Skill> skills) {
    final groups = <String, List<Skill>>{};
    for (final skill in skills) {
      groups.putIfAbsent(_groupOf(skill), () => []).add(skill);
    }

    int rank(String name) {
      final index = _order.indexOf(name);
      return index < 0 ? 999 : index;
    }

    final keys = groups.keys.toList()
      ..sort((a, b) {
        final byRank = rank(a).compareTo(rank(b));
        return byRank != 0 ? byRank : a.compareTo(b);
      });

    return {
      for (final key in keys)
        key: (groups[key]!..sort((a, b) => a.nameRu.compareTo(b.nameRu))),
    };
  }

  Widget _buildSearch() {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) =>
            setState(() => _query = value.trim().toLowerCase()),
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Поиск навыка',
          hintStyle: TextStyle(color: colors.textMuted),
          prefixIcon: Icon(Icons.search, color: colors.textMuted),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSelectedBlock(List<Skill> selected) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Выбрано: ${selected.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => widget.onChanged([]),
                child: Text(
                  'Сбросить',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selected
                .map(
                  (skill) => SkillChip(
                    skill: skill,
                    isSelected: true,
                    onTap: () => _toggle(skill),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(String name, List<Skill> skills, {required bool isOpen}) {
    final colors = context.colors;
    final selectedCount = skills
        .where((s) => widget.selectedSkillIds.contains(s.id))
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _query.isNotEmpty
                ? null
                : () => setState(() {
                    if (!_expanded.remove(name)) _expanded.add(name);
                  }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  if (selectedCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: context.accentColor,
                        ),
                      ),
                    ),
                  Text(
                    '${skills.length}',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map(
                      (skill) => SkillChip(
                        skill: skill,
                        isSelected: widget.selectedSkillIds.contains(skill.id),
                        onTap: () => _toggle(skill),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final skillsAsync = ref.watch(skillsListProvider);
    final colors = context.colors;

    return skillsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        'Не удалось загрузить навыки',
        style: TextStyle(color: Colors.red.shade400),
      ),
      data: (skills) {
        final groups = _group(skills);

        // При первом показе раскрываем сферы, где уже есть выбранные навыки
        if (!_expandedInitialized) {
          _expandedInitialized = true;
          for (final entry in groups.entries) {
            if (entry.value.any(
              (s) => widget.selectedSkillIds.contains(s.id),
            )) {
              _expanded.add(entry.key);
            }
          }
        }

        final selected = skills
            .where((s) => widget.selectedSkillIds.contains(s.id))
            .toList();

        final visible = <MapEntry<String, List<Skill>>>[];
        for (final entry in groups.entries) {
          final matches = _query.isEmpty
              ? entry.value
              : entry.value
                    .where((s) => s.nameRu.toLowerCase().contains(_query))
                    .toList();
          if (matches.isNotEmpty) visible.add(MapEntry(entry.key, matches));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearch(),
            const SizedBox(height: 12),
            if (selected.isNotEmpty) ...[
              _buildSelectedBlock(selected),
              const SizedBox(height: 12),
            ],
            if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Ничего не найдено',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                ),
              )
            else
              ...visible.map(
                (entry) => _buildGroup(
                  entry.key,
                  entry.value,
                  isOpen: _query.isNotEmpty || _expanded.contains(entry.key),
                ),
              ),
          ],
        );
      },
    );
  }
}
