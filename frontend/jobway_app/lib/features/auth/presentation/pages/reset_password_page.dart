import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _reset() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackbar.showError('Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            widget.email,
            _newPasswordController.text,
            _confirmPasswordController.text,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
      AppSnackbar.showSuccess('Пароль успешно изменён');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, foregroundColor: const Color(0xFF111827)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Text('Новый пароль',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 6),
              const Text('Придумайте новый пароль для входа',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 28),
              AppTextField(
                controller: _newPasswordController,
                label: 'Новый пароль',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Повторите пароль',
                icon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Сохранить пароль', isLoading: _isLoading, onPressed: _reset),
            ],
          ),
        ),
      ),
    );
  }
}