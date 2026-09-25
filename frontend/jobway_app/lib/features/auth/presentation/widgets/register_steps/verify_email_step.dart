import 'package:flutter/material.dart';
import '../../../../../core/widgets/otp_input.dart';

class VerifyEmailStep extends StatelessWidget {
  final String email;
  final ValueChanged<String> onCodeCompleted;
  final bool isLoading;
  final bool isResending;
  final VoidCallback onResend;

  const VerifyEmailStep({
    super.key,
    required this.email,
    required this.onCodeCompleted,
    required this.isLoading,
    required this.isResending,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Введите код', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        Text('Мы отправили 6-значный код на $email', style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 32),
        OtpInput(onCompleted: onCodeCompleted),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Center(
            child: TextButton(
              onPressed: isResending ? null : onResend,
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
              child: Text(isResending ? 'Отправка...' : 'Отправить код повторно'),
            ),
          ),
      ],
    );
  }
}