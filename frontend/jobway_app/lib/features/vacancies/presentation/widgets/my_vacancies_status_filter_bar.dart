import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class MyVacanciesStatusFilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;

  const MyVacanciesStatusFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _options = [
    (label: 'Все', value: null),
    (label: 'Черновики', value: 'Draft'),
    (label: 'Активные', value: 'Active'),
    (label: 'Закрытые', value: 'Closed'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final option = _options[index];
          final isSelected = selected == option.value;

          return GestureDetector(
            onTap: () => onSelected(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.textPrimary : colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.surface : colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}