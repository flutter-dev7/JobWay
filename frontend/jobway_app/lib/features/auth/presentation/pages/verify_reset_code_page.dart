import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/otp_input.dart';
import '../providers/auth_provider.dart';
import 'reset_password_page.dart';

class VerifyResetCodePage extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetCodePage({super.key, required this.email});

  @override
  ConsumerState<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
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
      await ref.read(authRepositoryProvider).verifyResetCode(widget.email, _code);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ResetPasswordPage(email: widget.email)));
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
              const Text('Введите код',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              const SizedBox(height: 6),
              Text('Мы отправили 6-значный код на ${widget.email}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 32),
              OtpInput(onCompleted: (value) => setState(() => _code = value)),
              const SizedBox(height: 24),
              AppButton(label: 'Подтвердить', isLoading: _isLoading, onPressed: _verify),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _resend,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
                  child: Text(_isResending ? 'Отправка...' : 'Отправить код повторно'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}