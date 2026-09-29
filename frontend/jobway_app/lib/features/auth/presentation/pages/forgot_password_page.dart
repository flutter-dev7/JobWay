import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/feedback/info_banner.dart';
import '../../../../core/widgets/display/step_progress_bar.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppSnackbar.showError('Введите email');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(email);
      if (!mounted) return;
      context.push(AppRoutes.verifyResetCode, extra: email);
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
      appBar: appPageAppBar(context, 'Забыли пароль?'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepProgressBar(currentStep: 0, totalSteps: 3),
              const SizedBox(height: 20),
              Text(
                'Введите email — мы отправим код подтверждения',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              const InfoBanner(
                text:
                    'Код действителен в течение 10 минут. Проверьте папку «Спам», если письмо не пришло сразу.',
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Отправить код',
                isLoading: _isLoading,
                onPressed: _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
