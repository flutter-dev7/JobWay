import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/today_badge_storage.dart';
import 'package:jobway_app/core/widgets/navigation/notification_bell.dart';
import 'package:jobway_app/features/vacancies/presentation/widgets/quick_filter_chips.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../providers/vacancies_provider.dart';
import '../widgets/vacancy_card.dart';
import '../widgets/vacancy_filter_sheet.dart';

class VacanciesListPage extends ConsumerStatefulWidget {
  const VacanciesListPage({super.key});

  @override
  ConsumerState<VacanciesListPage> createState() => _VacanciesListPageState();
}

class _VacanciesListPageState extends ConsumerState<VacanciesListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _showTodayBadge = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkTodayBadge();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkTodayBadge() async {
    final dismissed = await TodayBadgeStorage.wasDismissedToday();
    if (mounted) setState(() => _showTodayBadge = !dismissed);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(vacanciesControllerProvider.notifier).loadMore();
    }
  }

  void _openFilters(VacancyFilter currentFilter) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => VacancyFilterSheet(
        currentFilter: currentFilter,
        onApply: (filter) =>
            ref.read(vacanciesControllerProvider.notifier).applyFilter(filter),
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    final current = ref.read(vacanciesControllerProvider).filter;
    ref
        .read(vacanciesControllerProvider.notifier)
        .applyFilter(
          current.copyWith(
            search: value.trim().isEmpty ? null : value.trim(),
            clearSearch: value.trim().isEmpty,
          ),
        );
  }

  void _onSearchChanged(String value) {
    if (value.trim().isEmpty) {
      final current = ref.read(vacanciesControllerProvider).filter;
      if (current.search != null) {
        ref
            .read(vacanciesControllerProvider.notifier)
            .applyFilter(current.copyWith(search: null, clearSearch: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vacanciesControllerProvider);
    final colors = context.colors;

    ref.listen(savedVacanciesProvider, (previous, next) {
      next.whenData((vacancies) {
        ref.read(savedVacancyIdsProvider.notifier).state = vacancies
            .map((v) => v.id)
            .toSet();
      });
    });

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Вакансии',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: const [NotificationBell()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(vacanciesControllerProvider.notifier).load(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final countAsync = ref.watch(todayVacanciesCountProvider);
                  final count = countAsync.valueOrNull;

                  if (!_showTodayBadge || count == null || count == 0)
                    return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () async {
                          await TodayBadgeStorage.dismissForToday();
                          if (mounted) setState(() => _showTodayBadge = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCE5FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Color(0xFF3157D5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$count новых сегодня',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3157D5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: Color(0xFF3157D5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _onSearchSubmitted,
                          onChanged: _onSearchChanged,
                          style: TextStyle(color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Поиск вакансий',
                            hintStyle: TextStyle(color: colors.textMuted),
                            prefixIcon: Icon(
                              Icons.search,
                              color: colors.textMuted,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: colors.textMuted,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _openFilters(state.filter),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuickFilterChips(
                  selectedEmploymentType: state.filter.employmentType,
                  onSelected: (value) {
                    ref
                        .read(vacanciesControllerProvider.notifier)
                        .applyFilter(
                          state.filter.copyWith(
                            employmentType: value,
                            clearEmploymentType: value == null,
                          ),
                        );
                  },
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else if (state.items.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Вакансии не найдены',
                    style: TextStyle(fontSize: 14, color: colors.textMuted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == state.items.length) {
                      return state.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox.shrink();
                    }

                    final vacancy = state.items[index];
                    return VacancyCard(
                      vacancy: vacancy,
                      onTap: () => context.push(AppRoutes.vacancy(vacancy.id)),
                    );
                  }, childCount: state.items.length + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
