import 'package:flutter/material.dart';

class QuickFilterChips extends StatelessWidget {
  final String? selectedEmploymentType;
  final ValueChanged<String?> onSelected;

  const QuickFilterChips({super.key, required this.selectedEmploymentType, required this.onSelected});

  static const _options = [
    (label: 'Все', value: null),
    (label: 'Полная занятость', value: 'FullTime'),
    (label: 'Удалённо', value: 'Remote'),
    (label: 'Частичная', value: 'PartTime'),
    (label: 'Стажировка', value: 'Internship'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _options[index];
          final isSelected = selectedEmploymentType == option.value;

          return GestureDetector(
            onTap: () => onSelected(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}