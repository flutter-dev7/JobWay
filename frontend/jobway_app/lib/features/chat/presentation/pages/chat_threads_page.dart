import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_thread_card.dart';

class ChatThreadsPage extends ConsumerWidget {
  const ChatThreadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(chatThreadsProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Чаты',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(chatThreadsProvider.future),
        child: threadsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                ApiException.extractMessage(error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (threads) => threads.isEmpty
              ? const EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Пока нет переписок',
                  subtitle: 'Начните чат из отклика на вакансию',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  itemCount: threads.length,
                  itemBuilder: (context, index) {
                    final thread = threads[index];
                    return ChatThreadCard(
                      thread: thread,
                      onTap: () async {
                        await context.push(
                          AppRoutes.chat(thread.jobApplicationId),
                          extra: ChatArgs(
                            otherUserId: thread.otherUserId,
                            otherUserName: thread.otherUserName,
                            otherUserPhotoUrl: thread.otherUserPhotoUrl,
                            otherUserActive: thread.otherUserActive,
                            vacancyTitle: thread.vacancyTitle,
                          ),
                        );
                        ref.invalidate(chatThreadsProvider);
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
