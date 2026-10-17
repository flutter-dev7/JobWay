import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/empty_state.dart';
import '../providers/saved_vacancies_controller.dart';
import '../providers/vacancies_provider.dart';
import '../widgets/vacancy_card.dart';

class SavedVacanciesPage extends ConsumerStatefulWidget {
  const SavedVacanciesPage({super.key});

  @override
  ConsumerState<SavedVacanciesPage> createState() => _SavedVacanciesPageState();
}

class _SavedVacanciesPageState extends ConsumerState<SavedVacanciesPage> {
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

  SavedVacanciesController get _controller =>
      ref.read(savedVacanciesControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Widget _buildBody(SavedVacanciesState state) {
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
        icon: LucideIcons.bookmark,
        title: 'Нет сохранённых вакансий',
        subtitle: 'Нажмите на значок закладки на вакансии, чтобы сохранить её',
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
        return VacancyCard(
          vacancy: vacancy,
          onTap: () => context.push(AppRoutes.vacancy(vacancy.id)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedVacanciesControllerProvider);
    final colors = context.colors;

    ref.listen(savedVacancyIdsLoaderProvider, (previous, next) {
      next.whenData((ids) {
        ref.read(savedVacancyIdsProvider.notifier).state = ids;
      });
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Сохранённые',
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