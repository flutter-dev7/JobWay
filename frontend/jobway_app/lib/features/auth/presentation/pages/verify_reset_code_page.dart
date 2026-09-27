import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/otp_input.dart';
import '../../../../core/widgets/display/step_progress_bar.dart';
import '../providers/auth_provider.dart';
import 'reset_password_page.dart';

class VerifyResetCodePage extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetCodePage({super.key, required this.email});

  @override
  ConsumerState<VerifyResetCodePage> createState() =>
      _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends ConsumerState<VerifyResetCodePage> {
  String _code = '';
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verify() async {
    if (_code.length != 6) {
      AppSnackbar.showError('Введите код полностью');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyResetCode(widget.email, _code);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordPage(email: widget.email),
        ),
      );
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(widget.email);
      AppSnackbar.showSuccess('Код отправлен повторно');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Введите код'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StepProgressBar(currentStep: 1, totalSteps: 3),
              const SizedBox(height: 20),
              Text(
                'Мы отправили 6-значный код на ${widget.email}',
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
              const SizedBox(height: 28),
              OtpInput(onCompleted: (value) => setState(() => _code = value)),
              const SizedBox(height: 24),
              AppButton(
                label: 'Подтвердить',
                isLoading: _isLoading,
                onPressed: _verify,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _resend,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                  ),
                  child: Text(
                    _isResending ? 'Отправка...' : 'Отправить код повторно',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
