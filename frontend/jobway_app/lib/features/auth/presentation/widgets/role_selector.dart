import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleSelector({super.key, required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: colors.surfaceMuted, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildOption(context, label: 'Кандидат', value: 'Candidate'),
          _buildOption(context, label: 'Работодатель', value: 'Employer'),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, {required String label, required String value}) {
    final isSelected = selectedRole == value;
    final colors = context.colors;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? context.accentColor : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}