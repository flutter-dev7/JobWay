import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/subscription.dart';
import '../subscription_contacts.dart';
import '../subscription_launcher.dart';

enum PromoteSheetResult { confirm, upgrade }

class PromoteVacancySheet extends StatelessWidget {
  final String vacancyTitle;
  final String companyName;
  final Subscription? subscription;

  const PromoteVacancySheet({
    super.key,
    required this.vacancyTitle,
    required this.companyName,
    required this.subscription,
  });

  static const _amber = Color(0xFFD97706);

  // Возвращает confirm (Pro подтвердил продвижение), upgrade (Free хочет Pro) или null
  static Future<PromoteSheetResult?> show(
    BuildContext context, {
    required String vacancyTitle,
    required String companyName,
    required Subscription? subscription,
  }) {
    return showModalBottomSheet<PromoteSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromoteVacancySheet(
        vacancyTitle: vacancyTitle,
        companyName: companyName,
        subscription: subscription,
      ),
    );
  }

  bool get _isPro => subscription?.isPro ?? false;
  int get _left => subscription?.promotionsLeft ?? 0;
  int get _limit => subscription?.promotionsLimit ?? 0;
  int get _days => subscription?.promotionDays ?? 7;

  Future<void> _orderOneTime(BuildContext context) async {
    if (SubscriptionContacts.telegramUsername.isEmpty) {
      AppSnackbar.showError('Контакты для заказа пока не указаны');
      return;
    }

    Navigator.pop(context);
    await SubscriptionLauncher.openTelegram(
      SubscriptionContacts.telegramUsername,
      'Здравствуйте! Хочу продвинуть вакансию «$vacancyTitle» в топ. Компания «$companyName».',
    );
  }

  Widget _primaryButton(BuildContext context, String label, VoidCallback onPressed) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.surface,
          elevation: 0,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _secondaryButton(BuildContext context, String label, VoidCallback onPressed) {
    final colors = context.colors;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: BorderSide(color: colors.border),
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _benefit(BuildContext context, String text) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 18, color: colors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;
    final noPromotionsLeft = _isPro && _left == 0;

    final lead = _isPro
        ? 'Вакансия поднимется в начало ленты кандидатов на $_days дней.'
        : 'Самостоятельное продвижение входит в тариф Pro: $_limit раза в месяц по $_days дней. '
              'Либо закажите разовое продвижение этой вакансии.';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lead,
          style: TextStyle(fontSize: 14, height: 1.5, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        _benefit(context, 'Янтарная лента «Топ» на карточке вакансии'),
        _benefit(context, 'Первые позиции в общей ленте вакансий'),
        if (_isPro) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Продвижений в этом месяце',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
                Text(
                  'осталось $_left из $_limit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: noPromotionsLeft
                        ? const Color(0xFFDC2626)
                        : context.accentColor,
                  ),
                ),
              ],
            ),
          ),
          if (noPromotionsLeft) ...[
            const SizedBox(height: 10),
            Text(
              'Лимит обновится 1-го числа следующего месяца.',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
          ],
        ],
        const SizedBox(height: 22),
        if (_isPro && !noPromotionsLeft)
          _primaryButton(
            context,
            'Продвинуть на $_days дней',
            () => Navigator.pop(context, PromoteSheetResult.confirm),
          )
        else if (!_isPro)
          _primaryButton(
            context,
            'Улучшить до Pro',
            () => Navigator.pop(context, PromoteSheetResult.upgrade),
          ),
        if (!_isPro || noPromotionsLeft) ...[
          if (!_isPro) const SizedBox(height: 10),
          _secondaryButton(
            context,
            'Заказать разовое продвижение',
            () => _orderOneTime(context),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _amber.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 24, color: _amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Продвинуть в топ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        vacancyTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildBody(context),
          ],
        ),
      ),
    );
  }
}