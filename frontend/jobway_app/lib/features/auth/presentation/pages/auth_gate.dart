import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/providers/core_providers.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _checking = true;
  bool _isLoggedIn = false;
  String? _role;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final tokenStorage = ref.read(tokenStorageProvider);
    final token = await tokenStorage.getAccessToken();
    final role = await tokenStorage.getRole();

    if (!mounted) return;
    setState(() {
      _isLoggedIn = token != null;
      _role = role;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn && _role != null) {
      return HomePage(role: _role!);
    }

    return const LoginPage();
  }
}