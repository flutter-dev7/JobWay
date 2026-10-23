import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/admin/presentation/widgets/admin_filter_chips.dart';
import 'package:jobway_app/features/admin/presentation/widgets/admin_search_field.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/search_provider.dart';
import '../widgets/company_search_card.dart';
import '../widgets/search_results_body.dart';
import 'company_public_page.dart';

class CompanySearchPage extends ConsumerStatefulWidget {
  const CompanySearchPage({super.key});

  @override
  ConsumerState<CompanySearchPage> createState() => _CompanySearchPageState();
}

class _CompanySearchPageState extends ConsumerState<CompanySearchPage> {
  final _scrollController = ScrollController();

  static const _labels = ['Все', 'С открытыми вакансиями'];
  static const List<String?> _filters = [null, 'withVacancies'];

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
      ref.read(companySearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companySearchControllerProvider);
    final controller = ref.read(companySearchControllerProvider.notifier);
    final colors = context.colors;
    final selectedIndex = _filters.indexOf(state.filter).clamp(0, _filters.length - 1);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Компании'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AdminSearchField(
              hint: 'Название, сфера или город',
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
              emptyIcon: Icons.domain_rounded,
              emptyTitle: 'Компании не найдены',
              emptySubtitle: 'Попробуйте изменить запрос',
              itemBuilder: (context, company) => CompanySearchCard(
                company: company,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompanyPublicPage(companyId: company.id),
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