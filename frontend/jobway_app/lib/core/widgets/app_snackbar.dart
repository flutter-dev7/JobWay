import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AppSnackbar {
  static void showError(String message) =>
      _show(message, background: const Color(0xFF111827), icon: Icons.error_outline);

  static void showSuccess(String message) =>
      _show(message, background: const Color(0xFF065F46), icon: Icons.check_circle_outline);

  static void _show(String message, {required Color background, required IconData icon}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
          ],
        ),
      ),
    );
  }
}