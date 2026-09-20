// features/vacancies/presentation/pages/vacancies_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/vacancy_filter.dart';
import '../providers/vacancies_provider.dart';
import '../widgets/vacancy_card.dart';
import '../widgets/vacancy_filter_sheet.dart';
import 'vacancy_detail_page.dart';

class VacanciesListPage extends ConsumerStatefulWidget {
  const VacanciesListPage({super.key});

  @override
  ConsumerState<VacanciesListPage> createState() => _VacanciesListPageState();
}

class _VacanciesListPageState extends ConsumerState<VacanciesListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(vacanciesControllerProvider.notifier).loadMore();
    }
  }

  void _openFilters(VacancyFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => VacancyFilterSheet(
        currentFilter: currentFilter,
        onApply: (filter) => ref.read(vacanciesControllerProvider.notifier).applyFilter(filter),
      ),
    );
  }

  void _onSearchSubmitted(String value) {
    final current = ref.read(vacanciesControllerProvider).filter;
    ref.read(vacanciesControllerProvider.notifier).applyFilter(
          current.copyWith(search: value.trim().isEmpty ? null : value.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vacanciesControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Вакансии',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(vacanciesControllerProvider.notifier).load(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: _onSearchSubmitted,
                          decoration: const InputDecoration(
                            hintText: 'Поиск вакансий',
                            prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.tune_rounded, color: Color(0xFF111827)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (state.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (state.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  ),
                ),
              )
            else if (state.items.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Вакансии не найдены', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)))),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => VacancyDetailPage(vacancyId: vacancy.id)),
                        ),
                      );
                    },
                    childCount: state.items.length + 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}