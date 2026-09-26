import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminProfilePage extends ConsumerWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDCE5FF),
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 32,
                        color: Color(0xFF3157D5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Администратор',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Выйти',
              color: const Color(0xFFDC2626),
              onPressed: () async {
                final confirmed = await confirmLogoutDialog(context);
                if (!confirmed) return;

                await ref.read(authRepositoryProvider).logout();
                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
