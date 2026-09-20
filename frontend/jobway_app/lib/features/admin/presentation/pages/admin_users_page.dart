// features/admin/presentation/pages/admin_users_page.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../providers/admin_provider.dart';
import '../widgets/user_moderation_card.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminUsersControllerProvider);
    final controller = ref.read(adminUsersControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Пользователи',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.error!, textAlign: TextAlign.center),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return UserModerationCard(
                    key: ValueKey(user.id),
                    user: user,
                    isUpdating: state.updatingId == user.id,
                    onToggle: () async {
                      try {
                        await controller.toggle(user);
                        AppSnackbar.showSuccess(
                          user.isActive
                              ? 'Пользователь заблокирован'
                              : 'Пользователь разблокирован',
                        );
                      } catch (error) {
                        AppSnackbar.showError(
                          ApiException.extractMessage(error),
                        );
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
