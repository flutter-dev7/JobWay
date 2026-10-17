import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/features/review/presentation/widgets/review_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../providers/applications_provider.dart';
import '../widgets/application_card.dart';
import '../widgets/application_status_filter_bar.dart';

class MyApplicationsPage extends ConsumerStatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  ConsumerState<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends ConsumerState<MyApplicationsPage> {
  final _scrollController = ScrollController();

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

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      ref.read(myApplicationsControllerProvider.notifier).loadMore();
    }
  }

  Widget _buildBody(MyApplicationsState state) {
    final controller = ref.read(myApplicationsControllerProvider.notifier);

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
      return state.filter.status == null
          ? const EmptyState(
              icon: LucideIcons.clipboardList,
              title: 'Вы ещё не откликались на вакансии',
              subtitle: 'Найдите подходящую вакансию и откликнитесь',
            )
          : const EmptyState(
              icon: LucideIcons.filterX,
              title: 'Нет откликов с таким статусом',
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

        final application = state.items[index];
        return ApplicationCard(
          application: application,
          onLeaveReview: () => ReviewBottomSheet.show(
            context,
            jobApplicationId: application.id,
            targetName: application.companyName,
            onSubmitted: controller.load,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myApplicationsControllerProvider);
    final controller = ref.read(myApplicationsControllerProvider.notifier);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мои отклики',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          ApplicationStatusFilterBar(
            selected: state.filter.status,
            onSelected: controller.applyStatus,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }
}
