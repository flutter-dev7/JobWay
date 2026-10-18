import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:jobway_app/core/widgets/navigation/notification_bell.dart';
import 'package:jobway_app/features/admin/presentation/pages/admin_company_detail_page.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_filter_chips.dart';
import '../widgets/admin_search_field.dart';
import '../widgets/company_moderation_card.dart';

class AdminCompaniesPage extends ConsumerStatefulWidget {
  const AdminCompaniesPage({super.key});

  @override
  ConsumerState<AdminCompaniesPage> createState() => _AdminCompaniesPageState();
}

class _AdminCompaniesPageState extends ConsumerState<AdminCompaniesPage> {
  final _scrollController = ScrollController();

  static const _labels = ['Все', 'На рассмотрении', 'Верифицированы', 'Отклонены'];
  static const List<String?> _statuses = [null, 'NotVerified', 'Verified', 'Rejected'];

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

  AdminCompaniesController get _controller =>
      ref.read(adminCompaniesControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Future<void> _verify(String id) async {
    try {
      await _controller.verify(id);
      AppSnackbar.showSuccess('Компания верифицирована');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    }
  }

  Future<void> _reject(String id) async {
    try {
      await _controller.reject(id);
      AppSnackbar.showSuccess('Заявка отклонена');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    }
  }

  Widget _buildBody(AdminCompaniesState state) {
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
        icon: Icons.business_outlined,
        title: 'Компаний нет',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final company = state.items[index];
        return CompanyModerationCard(
          key: ValueKey(company.id),
          company: company,
          isUpdating: state.updatingId == company.id,
          onVerify: () => _verify(company.id),
          onReject: () => _reject(company.id),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminCompanyDetailPage(company: company),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminCompaniesControllerProvider);
    final colors = context.colors;
    final selectedIndex = _statuses.indexOf(state.status).clamp(0, _statuses.length - 1);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Компании',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: const [NotificationBell()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AdminSearchField(
              hint: 'Поиск по названию',
              onChanged: _controller.applySearch,
            ),
          ),
          AdminFilterChips(
            labels: _labels,
            selectedIndex: selectedIndex,
            onSelected: (index) => _controller.applyStatus(_statuses[index]),
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