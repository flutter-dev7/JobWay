import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/network/api_exception.dart';
import 'package:jobway_app/features/home/presentation/pages/home_page.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_selector.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'Candidate';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) =>
            AppSnackbar.showError(ApiException.extractMessage(error)),
        data: (result) {
          if (result != null) {
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(role: result.role)),
            );
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 72,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Создать аккаунт',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Найдите работу или наймите специалиста',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 28),
                        RoleSelector(
                          selectedRole: _role,
                          onChanged: (value) => setState(() => _role = value),
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _nameController,
                          label: _role == 'Candidate'
                              ? 'Имя и фамилия'
                              : 'Название компании',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Пароль',
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
                          label: 'Зарегистрироваться',
                          isLoading: authState.isLoading,
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .register(
                                email: _emailController.text.trim(),
                                password: _passwordController.text,
                                confirmPassword:
                                    _confirmPasswordController.text,
                                role: _role,
                                name: _nameController.text.trim(),
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Уже есть аккаунт?',
                              style: TextStyle(color: Color(0xFF6B7280)),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Войти',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
