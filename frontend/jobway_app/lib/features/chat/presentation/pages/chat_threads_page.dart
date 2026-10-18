import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_threads_controller.dart';
import '../widgets/chat_thread_card.dart';

class ChatThreadsPage extends ConsumerStatefulWidget {
  const ChatThreadsPage({super.key});

  @override
  ConsumerState<ChatThreadsPage> createState() => _ChatThreadsPageState();
}

class _ChatThreadsPageState extends ConsumerState<ChatThreadsPage> {
  final _scrollController = ScrollController();

  static const _filters = [
    (label: 'Все', unreadOnly: false),
    (label: 'Непрочитанные', unreadOnly: true),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  ChatThreadsController get _controller =>
      ref.read(chatThreadsControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Widget _buildFilters() {
    final colors = context.colors;
    final unreadOnly = ref.watch(chatUnreadOnlyProvider);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = unreadOnly == filter.unreadOnly;

          return GestureDetector(
            onTap: () =>
                ref.read(chatUnreadOnlyProvider.notifier).state = filter.unreadOnly,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? colors.textPrimary : colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.surface : colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(ChatThreadsState state) {
    final unreadOnly = ref.watch(chatUnreadOnlyProvider);

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Text(state.error!, textAlign: TextAlign.center),
        ],
      );
    }

    if (state.items.isEmpty) {
      return unreadOnly
          ? const EmptyState(
              icon: LucideIcons.messageCircle,
              title: 'Нет непрочитанных чатов',
            )
          : const EmptyState(
              icon: LucideIcons.messageCircle,
              title: 'Пока нет переписок',
              subtitle: 'Начните чат из отклика на вакансию',
            );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final thread = state.items[index];
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
            _controller.load();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatThreadsControllerProvider);
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
      body: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.load,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }
}