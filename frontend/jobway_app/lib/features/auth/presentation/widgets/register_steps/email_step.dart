import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_text_field.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Ваш email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Мы отправим код подтверждения', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        AppTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        AppButton(label: 'Отправить код', isLoading: isLoading, onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}