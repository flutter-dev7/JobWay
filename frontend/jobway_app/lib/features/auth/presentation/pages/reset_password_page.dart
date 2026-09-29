import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/widgets/display/step_progress_bar.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
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
      await ref
          .read(authRepositoryProvider)
          .resetPassword(
            widget.email,
            _newPasswordController.text,
            _confirmPasswordController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.login);
      AppSnackbar.showSuccess('Пароль успешно изменён');
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
      appBar: appPageAppBar(context, 'Новый пароль'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepProgressBar(currentStep: 2, totalSteps: 3),
              const SizedBox(height: 20),
              Text(
                'Придумайте новый пароль для входа',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
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
              AppButton(
                label: 'Сохранить пароль',
                isLoading: _isLoading,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
