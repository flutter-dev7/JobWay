import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AdminProfilePage extends ConsumerWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
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
                color: colors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 0.035,
                    ),
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
                      color: colors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 3),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 32,
                        color: context.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Администратор',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
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

                context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
