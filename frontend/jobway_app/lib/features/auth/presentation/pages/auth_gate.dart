import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/constants/api_constants.dart';
import 'package:jobway_app/core/providers/core_providers.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  static const _maxAttempts = 5;

  bool _checking = true;
  bool _isLoggedIn = false;
  String? _role;
  bool _serverUnreachable = false;
  String _statusText = 'Загрузка...';

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _checking = true;
      _serverUnreachable = false;
      _statusText = 'Загрузка...';
    });

    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getAccessToken();
    final role = await tokenStorage.getRole();

    final serverReady = await _waitForServer();

    if (!mounted) return;

    if (!serverReady) {
      setState(() {
        _checking = false;
        _serverUnreachable = true;
      });
      return;
    }

    setState(() {
      _isLoggedIn = token != null;
      _role = role;
      _checking = false;
    });
  }

  Future<bool> _waitForServer() async {
    final dio = ref.read(dioClientProvider).dio;

    for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
      if (!mounted) return false;

      if (attempt > 1) {
        setState(() => _statusText = 'Подключаемся к серверу... ($attempt/$_maxAttempts)');
      }

      try {
        await dio.get(
          ApiConstants.health,
          options: Options(
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );
        return true;
      } catch (_) {
        if (attempt == _maxAttempts) return false;
        await Future.delayed(const Duration(seconds: 3));
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_checking) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(_statusText, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_serverUnreachable) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: colors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Не удалось подключиться к серверу',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Проверьте интернет-соединение и попробуйте снова',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _check,
                  child: const Text('Повторить попытку'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoggedIn && _role != null) {
      return HomePage(role: _role!);
    }

    return const LoginPage();
  }
}