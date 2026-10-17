import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../../../vacancies/presentation/providers/my_vacancies_controller.dart';

class ApplicationsOverviewPage extends ConsumerStatefulWidget {
  const ApplicationsOverviewPage({super.key});

  @override
  ConsumerState<ApplicationsOverviewPage> createState() =>
      _ApplicationsOverviewPageState();
}

class _ApplicationsOverviewPageState
    extends ConsumerState<ApplicationsOverviewPage> {
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

  MyVacanciesController get _controller =>
      ref.read(applicationsOverviewControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Widget _buildBody(MyVacanciesState state) {
    final colors = context.colors;

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
      return const EmptyState(
        icon: LucideIcons.inbox,
        title: 'У вас пока нет вакансий',
        subtitle: 'Создайте вакансию, чтобы начать получать отклики',
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

        final vacancy = state.items[index];
        return GestureDetector(
          onTap: () => context.push(
            AppRoutes.vacancyApplications(vacancy.id),
            extra: VacancyApplicationsArgs(
              title: vacancy.title,
              status: vacancy.status,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.dark
                        ? 0.2
                        : 0.03,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.people_outline_rounded,
                    size: 20,
                    color: context.accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vacancy.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(LucideIcons.chevronRight, color: colors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationsOverviewControllerProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Отклики',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _controller.load,
        child: _buildBody(state),
      ),
    );
  }
}