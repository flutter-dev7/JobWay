import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/subscription.dart';
import '../providers/subscription_provider.dart';
import '../subscription_contacts.dart';
import '../subscription_launcher.dart';

class SubscriptionSheet extends ConsumerStatefulWidget {
  final String companyName;

  const SubscriptionSheet({super.key, this.companyName = ''});

  static Future<void> show(BuildContext context, {String companyName = ''}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionSheet(companyName: companyName),
    );
  }

  @override
  ConsumerState<SubscriptionSheet> createState() => _SubscriptionSheetState();
}

class _SubscriptionSheetState extends ConsumerState<SubscriptionSheet> {
  static const _proColor = Color(0xFFF59E0B);

  bool _yearly = false;

  Future<void> _contact() async {
    final hasTelegram = SubscriptionContacts.telegramUsername.isNotEmpty;
    final hasPhone = SubscriptionContacts.phone.isNotEmpty;

    if (!hasTelegram && !hasPhone) {
      AppSnackbar.showError('Контакты для оформления пока не указаны');
      return;
    }

    if (hasTelegram) {
      final period = _yearly ? '1 год' : '1 месяц';
      final name = widget.companyName.trim();
      final who = name.isNotEmpty ? 'Компания «$name»' : 'Наша компания';

      await SubscriptionLauncher.openTelegram(
        SubscriptionContacts.telegramUsername,
        'Здравствуйте! $who хочет оформить тариф Pro на $period.',
      );
    } else {
      await SubscriptionLauncher.callPhone(SubscriptionContacts.phone);
    }
  }

  void _showLimits() {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Лимиты тарифов'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Free: до ${SubscriptionContacts.freeLimit} активных вакансий одновременно.\n'
            'Pro: до ${SubscriptionContacts.proLimit} активных вакансий одновременно.\n\n'
            'Приглашения кандидатов: Free ${SubscriptionContacts.freeInvitations} в день, '
            'Pro ${SubscriptionContacts.proInvitations} в день.\n\n'
            'В лимит входят только опубликованные (активные) вакансии. '
            'Черновики и закрытые вакансии не учитываются.\n\n'
            'Если срок Pro закончится, уже опубликованные вакансии продолжат '
            'работать, но новые сверх лимита Free опубликовать не получится.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close_rounded, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final colors = context.colors;

    return Column(
      children: [
        Text(
          'Больше возможностей',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Выберите подходящий план',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanHeader(Subscription subscription) {
    final colors = context.colors;
    final isPro = subscription.isPro;
    final chipColor = isPro ? _proColor : colors.textSecondary;
    final chipText = isPro && subscription.tierExpiresAt != null
        ? 'Активен до ${TimeAgo.formatDate(subscription.tierExpiresAt!)}'
        : 'Сейчас: Free';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pro',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                chipText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: chipColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Для растущих компаний',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUsage(Subscription subscription) {
    final colors = context.colors;
    final color = subscription.isLimitReached
        ? const Color(0xFFDC2626)
        : context.accentColor;
    final progress = subscription.activeVacanciesLimit == 0
        ? 0.0
        : (subscription.activeVacanciesCount /
                  subscription.activeVacanciesLimit)
              .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Активные вакансии',
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
              Text(
                '${subscription.activeVacanciesCount} из ${subscription.activeVacanciesLimit}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Черновики и закрытые вакансии не учитываются',
            style: TextStyle(fontSize: 11, color: colors.textMuted),
          ),
          if (subscription.invitationsLimit > 0) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Приглашений кандидатов сегодня',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  '${subscription.invitationsUsed} из ${subscription.invitationsLimit}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: subscription.isInvitationLimitReached
                        ? const Color(0xFFDC2626)
                        : context.accentColor,
                  ),
                ),
              ],
            ),
          ],
          if (subscription.isPro) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Продвижений в этом месяце',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  '${subscription.promotionsUsed} из ${subscription.promotionsLimit}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlans() {
    final monthlyPrice = SubscriptionContacts.monthlyPrice;
    final yearlyPrice = SubscriptionContacts.yearlyPrice;
    final yearlyBadge = SubscriptionContacts.yearlyBadge;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _PlanTile(
              title: monthlyPrice.isNotEmpty ? monthlyPrice : '1 месяц',
              caption: 'Ежемесячная оплата',
              selected: !_yearly,
              onTap: () => setState(() => _yearly = false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PlanTile(
              title: yearlyPrice.isNotEmpty ? yearlyPrice : '1 год',
              caption: 'Оплата раз в год',
              badge: yearlyBadge.isNotEmpty ? yearlyBadge : null,
              selected: _yearly,
              onTap: () => setState(() => _yearly = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final colors = context.colors;
    final benefits = [
      'До ${SubscriptionContacts.proLimit} активных вакансий одновременно',
      'Полная аналитика по вакансиям',
      'Продвижение в топ: 2 раза в месяц по 7 дней',
      'Приглашения кандидатов: до ${SubscriptionContacts.proInvitations} в день (в Free ${SubscriptionContacts.freeInvitations})',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Всё, что есть в Free, плюс:',
          style: TextStyle(fontSize: 13, color: colors.textSecondary),
        ),
        const SizedBox(height: 12),
        ...benefits.map(
          (benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: colors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProCard(Subscription subscription) {
    final colors = context.colors;
    final hasPhone = SubscriptionContacts.phone.isNotEmpty;
    final hasTelegram = SubscriptionContacts.telegramUsername.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHeader(subscription),
          const SizedBox(height: 18),
          _buildUsage(subscription),
          const SizedBox(height: 20),
          _buildPlans(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _contact,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.surface,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: Text(
                subscription.isPro ? 'Продлить план Pro' : 'Оформить план Pro',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (hasPhone && hasTelegram)
            Center(
              child: TextButton(
                onPressed: () =>
                    SubscriptionLauncher.callPhone(SubscriptionContacts.phone),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                ),
                child: Text('Или позвонить: ${SubscriptionContacts.phone}'),
              ),
            ),
          const SizedBox(height: 6),
          Text(
            SubscriptionContacts.paymentNote,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: colors.border),
          const SizedBox(height: 18),
          _buildBenefits(),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _showLimits,
            child: Text(
              'Действуют лимиты',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider).valueOrNull;
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: subscription == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          24 + MediaQuery.of(context).padding.bottom,
                        ),
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 24),
                          _buildProCard(subscription),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String caption;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.title,
    required this.caption,
    this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RadioDot(selected: selected),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.accentColor;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? accent : Colors.transparent,
        border: Border.all(color: selected ? accent : colors.border, width: 2),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
