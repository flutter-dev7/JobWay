import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_extension.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';

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
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Придумайте пароль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        const SizedBox(height: 6),
        Text('Минимум 6 символов', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
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