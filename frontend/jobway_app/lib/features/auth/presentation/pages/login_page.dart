import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/network/api_exception.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colors = context.colors;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) =>
            AppSnackbar.showError(ApiException.extractMessage(error)),
        data: (result) {
          if (result != null) {
            _emailController.clear();
            _passwordController.clear();
            context.go(AppRoutes.home(result.role));
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: colors.background,
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
                            Theme.of(context).brightness == Brightness.dark
                                ? 'assets/images/logo_dark.png'
                                : 'assets/images/logo.png',
                            height: 72,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'С возвращением',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Войдите, чтобы продолжить поиск работы',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: context.accentColor,
                            ),
                            onPressed: () {
                              context.push(AppRoutes.forgotPassword);
                            },
                            child: const Text('Забыли пароль?'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'Войти',
                          isLoading: authState.isLoading,
                          onPressed: () => ref
                              .read(authControllerProvider.notifier)
                              .login(
                                _emailController.text.trim(),
                                _passwordController.text,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Нет аккаунта?',
                              style: TextStyle(color: colors.textSecondary),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: context.accentColor,
                              ),
                              onPressed: () {
                                context.push(AppRoutes.register);
                              },
                              child: const Text(
                                'Зарегистрироваться',
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
