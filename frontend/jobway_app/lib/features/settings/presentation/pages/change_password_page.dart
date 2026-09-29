import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_oldPasswordController.text.isEmpty) {
      AppSnackbar.showError('Введите текущий пароль');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      AppSnackbar.showError('Новый пароль должен быть не короче 6 символов');
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      AppSnackbar.showError('Пароли не совпадают');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .changePassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );
      if (!mounted) return;
      AppSnackbar.showSuccess('Пароль изменён');
      context.pop();
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Сменить пароль'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          AppTextField(
            controller: _oldPasswordController,
            label: 'Текущий пароль',
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _newPasswordController,
            label: 'Новый пароль',
            icon: Icons.lock_reset_outlined,
            isPassword: true,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Подтвердите новый пароль',
            icon: Icons.lock_reset_outlined,
            isPassword: true,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Сохранить',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
