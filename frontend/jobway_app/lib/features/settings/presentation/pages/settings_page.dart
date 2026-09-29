import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/theme_mode_selector.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmLogoutDialog(context);
    if (!confirmed) return;

    await ref.read(authRepositoryProvider).logout();
    if (!context.mounted) return;

    context.go(AppRoutes.login);
  }

  Future<void> _toggleNotifications(WidgetRef ref, bool value) async {
    await ref.read(notificationsEnabledProvider.notifier).setEnabled(value);
    try {
      if (value) {
        await ref.read(pushNotificationServiceProvider).registerToken();
      } else {
        await ref.read(pushNotificationServiceProvider).unregisterToken();
      }
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Настройки'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          SectionCard(
            title: 'Аккаунт',
            icon: Icons.person_outline_rounded,
            child: SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Сменить пароль',
              onTap: () => context.push(AppRoutes.changePassword),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Оформление',
            icon: Icons.palette_outlined,
            child: ThemeModeSelector(
              selected: themeMode,
              onChanged: (mode) => ref.read(themeModeProvider.notifier).setThemeMode(mode),
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Уведомления',
            icon: Icons.notifications_outlined,
            child: SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Push-уведомления',
              subtitle: 'Новые отклики, статусы, совпадения по вакансиям',
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: context.accentColor,
                onChanged: (value) => _toggleNotifications(ref, value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Выйти из аккаунта',
            iconColor: const Color(0xFFDC2626),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}