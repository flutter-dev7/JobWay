import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

class PasswordStep extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool canContinue;
  final VoidCallback onContinue;

  const PasswordStep({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Придумайте пароль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Минимум 6 символов', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        AppTextField(controller: passwordController, label: 'Пароль', icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 14),
        AppTextField(controller: confirmPasswordController, label: 'Повторите пароль', icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 28),
        AppButton(label: 'Продолжить', onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}