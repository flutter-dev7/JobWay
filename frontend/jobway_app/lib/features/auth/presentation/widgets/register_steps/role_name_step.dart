import 'package:flutter/material.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';
import '../role_selector.dart';

class RoleNameStep extends StatelessWidget {
  final String role;
  final TextEditingController nameController;
  final ValueChanged<String> onRoleChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  const RoleNameStep({
    super.key,
    required this.role,
    required this.nameController,
    required this.onRoleChanged,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Кто вы?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Выберите роль и представьтесь', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        RoleSelector(selectedRole: role, onChanged: onRoleChanged),
        const SizedBox(height: 18),
        AppTextField(
          controller: nameController,
          label: role == 'Candidate' ? 'Имя и фамилия' : 'Название компании',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 28),
        AppButton(label: 'Продолжить', onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}