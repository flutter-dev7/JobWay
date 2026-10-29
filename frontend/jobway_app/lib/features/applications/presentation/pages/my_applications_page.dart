import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/features/invitations/domain/entities/invitation.dart';
import 'package:jobway_app/features/invitations/presentation/providers/invitations_provider.dart';
import 'package:jobway_app/features/invitations/presentation/widgets/invitation_card.dart';
import 'package:jobway_app/features/review/presentation/widgets/review_bottom_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
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
  String? _busyInvitationId;

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

  Future<void> _refresh() async {
    ref.invalidate(pendingInvitationsProvider);
    await ref.read(myApplicationsControllerProvider.notifier).load();
  }

  Future<void> _accept(Invitation invitation) async {
    setState(() => _busyInvitationId = invitation.id);
    try {
      await ref.read(acceptInvitationUseCaseProvider).call(invitation.id);
      AppSnackbar.showSuccess('Отклик отправлен');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      // Отклик мог создаться, даже если ответ пришёл с ошибкой: списки обновляем всегда
      if (mounted) {
        ref.invalidate(pendingInvitationsProvider);
        ref.invalidate(myAppliedVacancyIdsProvider);
        ref.read(myApplicationsControllerProvider.notifier).load();
        setState(() => _busyInvitationId = null);
      }
    }
  }

  Future<bool> _confirmDecline(Invitation invitation) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Отклонить приглашение?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '«${invitation.companyName}» получит уведомление. '
            'Пригласить вас на эту вакансию повторно будет нельзя.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Отклонить'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _decline(Invitation invitation) async {
    final confirmed = await _confirmDecline(invitation);
    if (!mounted || !confirmed) return;

    setState(() => _busyInvitationId = invitation.id);
    try {
      await ref.read(declineInvitationUseCaseProvider).call(invitation.id);
      AppSnackbar.showSuccess('Приглашение отклонено');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) {
        ref.invalidate(pendingInvitationsProvider);
        setState(() => _busyInvitationId = null);
      }
    }
  }

  Widget _sectionTitle(String text) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
      ),
    );
  }

  // Что показать вместо списка откликов: загрузка, ошибка или пустое состояние
  Widget _buildPlaceholder(MyApplicationsState state) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(state.error!, textAlign: TextAlign.center),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: state.filter.status == null
          ? const EmptyState(
              icon: LucideIcons.clipboardList,
              title: 'Вы ещё не откликались на вакансии',
              subtitle: 'Найдите подходящую вакансию и откликнитесь',
            )
          : const EmptyState(
              icon: LucideIcons.filterX,
              title: 'Нет откликов с таким статусом',
            ),
    );
  }

  Widget _buildBody(MyApplicationsState state, List<Invitation> invitations) {
    final controller = ref.read(myApplicationsControllerProvider.notifier);

    // Заголовок «Вас пригласили», карточки приглашений и заголовок «Мои отклики»
    final headerCount = invitations.isEmpty ? 0 : invitations.length + 2;
    final applicationsCount = state.items.isEmpty
        ? 1
        : state.items.length + (state.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: headerCount + applicationsCount,
      itemBuilder: (context, index) {
        if (index < headerCount) {
          if (index == 0) {
            return _sectionTitle('Вас пригласили · ${invitations.length}');
          }
          if (index == headerCount - 1) return _sectionTitle('Мои отклики');

          final invitation = invitations[index - 1];
          return InvitationCard(
            invitation: invitation,
            isBusy: _busyInvitationId == invitation.id,
            onAccept: () => _accept(invitation),
            onDecline: () => _decline(invitation),
            onOpenVacancy: () => context.push(AppRoutes.vacancy(invitation.vacancyId)),
          );
        }

        final i = index - headerCount;

        if (state.items.isEmpty) return _buildPlaceholder(state);

        if (i >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final application = state.items[i];
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
    final invitations =
        ref.watch(pendingInvitationsProvider).valueOrNull ?? const <Invitation>[];
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
              onRefresh: _refresh,
              child: _buildBody(state, invitations),
            ),
          ),
        ],
      ),
    );
  }
}