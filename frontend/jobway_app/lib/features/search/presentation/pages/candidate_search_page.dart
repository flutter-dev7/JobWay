import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/admin/presentation/widgets/admin_filter_chips.dart';
import 'package:jobway_app/features/admin/presentation/widgets/admin_search_field.dart';
import 'package:jobway_app/features/candidate_profile/presentation/pages/candidate_profile_view_page.dart';
import 'package:jobway_app/features/skills/domain/skill_categories.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/search_provider.dart';
import '../widgets/candidate_search_card.dart';
import '../widgets/search_results_body.dart';

class CandidateSearchPage extends ConsumerStatefulWidget {
  const CandidateSearchPage({super.key});

  @override
  ConsumerState<CandidateSearchPage> createState() =>
      _CandidateSearchPageState();
}

class _CandidateSearchPageState extends ConsumerState<CandidateSearchPage> {
  final _scrollController = ScrollController();

  static const _labels = ['Все сферы', ...skillCategories];
  static const List<String?> _filters = [null, ...skillCategories];

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
      ref.read(candidateSearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(candidateSearchControllerProvider);
    final controller = ref.read(candidateSearchControllerProvider.notifier);
    final colors = context.colors;
    final selectedIndex = _filters
        .indexOf(state.filter)
        .clamp(0, _filters.length - 1);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Кандидаты'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AdminSearchField(
              hint: 'Имя, навык или город',
              onChanged: controller.applyQuery,
            ),
          ),
          AdminFilterChips(
            labels: _labels,
            selectedIndex: selectedIndex,
            onSelected: (index) => controller.applyFilter(_filters[index]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Найдено: ${state.totalCount}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            child: SearchResultsBody(
              state: state,
              scrollController: _scrollController,
              onRefresh: controller.load,
              emptyIcon: Icons.person_search_rounded,
              emptyTitle: 'Кандидаты не найдены',
              emptySubtitle:
                  'В поиске видны только кандидаты, которые открыли профиль для работодателей',
              itemBuilder: (context, candidate) => CandidateSearchCard(
                candidate: candidate,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CandidateProfileViewPage(
                      candidateProfileId: candidate.id,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
