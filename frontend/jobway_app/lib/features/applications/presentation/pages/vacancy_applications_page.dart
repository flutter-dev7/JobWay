import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import 'package:jobway_app/features/review/presentation/widgets/review_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/vacancy_applications_controller.dart';
import '../widgets/application_status_filter_bar.dart';
import '../widgets/vacancy_application_card.dart';

class VacancyApplicationsPage extends ConsumerStatefulWidget {
  final String vacancyId;
  final String vacancyTitle;
  final String vacancyStatus;

  const VacancyApplicationsPage({
    super.key,
    required this.vacancyId,
    required this.vacancyTitle,
    required this.vacancyStatus,
  });

  @override
  ConsumerState<VacancyApplicationsPage> createState() =>
      _VacancyApplicationsPageState();
}

class _VacancyApplicationsPageState
    extends ConsumerState<VacancyApplicationsPage> {
  final _scrollController = ScrollController();
  String? _updatingApplicationId;

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

  VacancyApplicationsController get _controller => ref.read(
    vacancyApplicationsControllerProvider(widget.vacancyId).notifier,
  );

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Future<void> _updateStatus(String applicationId, String status) async {
    setState(() => _updatingApplicationId = applicationId);
    try {
      await _controller.updateStatus(applicationId, status);
      AppSnackbar.showSuccess('Статус обновлён');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingApplicationId = null);
    }
  }

  String _applicationsCountLabel(int count) {
    final mod10 = count % 10;
    final mod100 = count % 100;
    final word = (mod10 == 1 && mod100 != 11)
        ? 'отклик'
        : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14))
        ? 'отклика'
        : 'откликов';
    return '$count $word';
  }

  Widget _buildHeader(VacancyApplicationsState state) {
    final colors = context.colors;
    final isByMatch = state.filter.sortBy == 'matchScore';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _applicationsCountLabel(state.totalCount),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          PopupMenuButton<String>(
            initialValue: state.filter.sortBy,
            onSelected: _controller.applySort,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'date', child: Text('Сначала новые')),
              PopupMenuItem(
                value: 'matchScore',
                child: Text('Лучшие совпадения'),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.arrowUpDown,
                  size: 18,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  isByMatch ? 'Лучшие совпадения' : 'Сначала новые',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(VacancyApplicationsState state, bool isLocked) {
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
              icon: Icons.people_outline_rounded,
              title: 'Пока нет откликов',
            )
          : const EmptyState(
              icon: LucideIcons.filterX,
              title: 'Нет откликов с таким статусом',
            );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final application = state.items[index];
        return VacancyApplicationCard(
          application: application,
          isUpdating: _updatingApplicationId == application.id,
          isLocked: isLocked,
          onStatusChanged: (status) => _updateStatus(application.id, status),
          onMessage: application.candidateAccountDeleted
              ? null
              : () async {
                  await context.push(
                    AppRoutes.chat(application.id),
                    extra: ChatArgs(
                      otherUserId: application.candidateProfileId,
                      otherUserName: application.candidateFullName,
                      otherUserPhotoUrl: application.candidatePhotoUrl,
                      vacancyTitle: application.vacancyTitle,
                    ),
                  );
                },
          onLeaveReview: () => ReviewBottomSheet.show(
            context,
            jobApplicationId: application.id,
            targetName: application.candidateFullName,
            onSubmitted: _controller.load,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      vacancyApplicationsControllerProvider(widget.vacancyId),
    );
    final isLocked = widget.vacancyStatus != 'Active';
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, widget.vacancyTitle),
      body: Column(
        children: [
          const SizedBox(height: 8),
          ApplicationStatusFilterBar(
            selected: state.filter.status,
            onSelected: _controller.applyStatus,
          ),
          _buildHeader(state),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _controller.load,
              child: _buildBody(state, isLocked),
            ),
          ),
        ],
      ),
    );
  }
}
