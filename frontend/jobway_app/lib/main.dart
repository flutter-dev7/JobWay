import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/network/dio_client.dart';
import 'package:jobway_app/core/widgets/app_snackbar.dart';
import 'package:jobway_app/features/auth/presentation/pages/auth_gate.dart';
import 'package:jobway_app/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
      },
    );
  }
}