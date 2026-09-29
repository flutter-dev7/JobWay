import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class ThemeModeSelector extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeModeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildOption(context, label: 'Светлая', icon: Icons.light_mode_outlined, value: ThemeMode.light),
          _buildOption(context, label: 'Тёмная', icon: Icons.dark_mode_outlined, value: ThemeMode.dark),
          _buildOption(context, label: 'Системная', icon: Icons.settings_suggest_outlined, value: ThemeMode.system),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required String label, required IconData icon, required ThemeMode value}) {
    final isSelected = selected == value;
    final colors = context.colors;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: isSelected ? context.accentColor : colors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? context.accentColor : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}