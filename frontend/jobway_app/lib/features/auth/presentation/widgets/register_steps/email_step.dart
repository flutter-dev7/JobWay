import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_extension.dart';
import '../../../../../core/widgets/buttons/app_button.dart';
import '../../../../../core/widgets/inputs/app_text_field.dart';

class EmailStep extends StatelessWidget {
  final TextEditingController emailController;
  final bool canContinue;
  final bool isLoading;
  final VoidCallback onContinue;

  const EmailStep({
    super.key,
    required this.emailController,
    required this.canContinue,
    required this.isLoading,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ваш email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Мы отправим код подтверждения',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        const SizedBox(height: 28),
        AppTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Отправить код',
          isLoading: isLoading,
          onPressed: canContinue ? onContinue : null,
        ),
      ],
    );
  }
}
