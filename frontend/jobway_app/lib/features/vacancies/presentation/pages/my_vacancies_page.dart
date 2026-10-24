import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/feedback/empty_state.dart';
import 'package:jobway_app/core/widgets/navigation/notification_bell.dart';
import 'package:jobway_app/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:jobway_app/features/search/presentation/widgets/search_entry_button.dart';
import 'package:jobway_app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:jobway_app/features/subscription/presentation/widgets/promote_vacancy_sheet.dart';
import 'package:jobway_app/features/subscription/presentation/widgets/subscription_sheet.dart';
import 'package:jobway_app/features/vacancies/domain/entities/vacancy.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/my_vacancies_controller.dart';
import '../widgets/my_vacancies_status_filter_bar.dart';
import '../widgets/my_vacancy_card.dart';

class MyVacanciesPage extends ConsumerStatefulWidget {
  const MyVacanciesPage({super.key});

  @override
  ConsumerState<MyVacanciesPage> createState() => _MyVacanciesPageState();
}

class _MyVacanciesPageState extends ConsumerState<MyVacanciesPage> {
  final _scrollController = ScrollController();
  String? _updatingVacancyId;

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
      ref.read(myVacanciesControllerProvider.notifier);

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _controller.loadMore();
    }
  }

  Future<void> _runAction(
    String id,
    Future<void> Function(String id) action,
    String successMessage,
  ) async {
    setState(() => _updatingVacancyId = id);
    try {
      await action(id);
      ref.invalidate(subscriptionProvider);
      ref.invalidate(employerAnalyticsProvider);
      AppSnackbar.showSuccess(successMessage);
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingVacancyId = null);
    }
  }

  Future<bool> _confirmPublish(Vacancy vacancy) async {
    final subscription = ref.read(subscriptionProvider).valueOrNull;

    if (subscription != null && subscription.isLimitReached) {
      final upgrade = await showCupertinoDialog<bool>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Достигнут лимит'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'На вашем тарифе можно держать до ${subscription.activeVacanciesLimit} '
              'активных вакансий. Закройте одну из них'
              '${subscription.isPro ? '.' : ' или перейдите на Pro.'}',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(subscription.isPro ? 'Понятно' : 'Закрыть'),
            ),
            if (!subscription.isPro)
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Улучшить до Pro'),
              ),
          ],
        ),
      );

      if (upgrade == true && mounted) {
        SubscriptionSheet.show(context, companyName: vacancy.companyName);
      }
      return false;
    }

    final slots = subscription == null
        ? ''
        : '\n\nПосле публикации активных вакансий будет '
              '${subscription.activeVacanciesCount + 1} из ${subscription.activeVacanciesLimit}.';

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Опубликовать вакансию?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Вакансия «${vacancy.title}» появится в ленте кандидатов, '
            'а подходящие кандидаты получат уведомление.$slots',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Опубликовать'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Future<void> _promote(Vacancy vacancy) async {
    final subscription = ref.read(subscriptionProvider).valueOrNull;

    final result = await PromoteVacancySheet.show(
      context,
      vacancyTitle: vacancy.title,
      companyName: vacancy.companyName,
      subscription: subscription,
    );
    if (!mounted || result == null) return;

    if (result == PromoteSheetResult.upgrade) {
      SubscriptionSheet.show(context, companyName: vacancy.companyName);
      return;
    }

    await _runAction(vacancy.id, _controller.promote, 'Вакансия поднята в топ');
  }

  Future<bool> _confirmClose(Vacancy vacancy) async {
    final text = vacancy.isFeatured
        ? 'Вакансия «${vacancy.title}» пропадёт из ленты кандидатов, а продвижение в топ закончится досрочно. Потраченное продвижение не возвращается.\n\nНовые отклики приходить не будут, существующие отклики и переписки останутся.'
        : 'Вакансия «${vacancy.title}» пропадёт из ленты кандидатов, новые отклики приходить не будут. Существующие отклики и переписки останутся.';

    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Закрыть вакансию?'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(text, textAlign: TextAlign.center),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );

    return result == true;
  }

  Widget _buildBody(MyVacanciesState state) {
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
              icon: LucideIcons.briefcase,
              title: 'У вас пока нет вакансий',
              subtitle: 'Нажмите «+», чтобы создать первую',
            )
          : const EmptyState(
              icon: LucideIcons.filterX,
              title: 'Нет вакансий с таким статусом',
            );
    }

    final isPro = ref.watch(subscriptionProvider).valueOrNull?.isPro ?? false;
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
        return MyVacancyCard(
          vacancy: vacancy,
          isUpdating: _updatingVacancyId == vacancy.id,
          onPublish: () async {
            final confirmed = await _confirmPublish(vacancy);
            if (!mounted || !confirmed) return;
            await _runAction(
              vacancy.id,
              _controller.publish,
              'Вакансия опубликована',
            );
          },
          onClose: () async {
            final confirmed = await _confirmClose(vacancy);
            if (!mounted || !confirmed) return;
            await _runAction(vacancy.id, _controller.close, 'Вакансия закрыта');
          },
          onPromote: () => _promote(vacancy),
          promoteLocked: !isPro,
          onEdit: () async {
            await context.push(AppRoutes.editVacancy, extra: vacancy);
            _controller.load();
            ref.invalidate(employerAnalyticsProvider);
          },
          onTap: () => context.push(
            AppRoutes.vacancyApplications(vacancy.id),
            extra: VacancyApplicationsArgs(
              title: vacancy.title,
              status: vacancy.status,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myVacanciesControllerProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мои вакансии',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          const SearchEntryButton(forEmployer: true),
          const NotificationBell(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(LucideIcons.plus, color: colors.textPrimary),
              onPressed: () async {
                await context.push(AppRoutes.createVacancy);
                _controller.load();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          MyVacanciesStatusFilterBar(
            selected: state.filter.status,
            onSelected: _controller.applyStatus,
          ),
          const SizedBox(height: 8),
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
