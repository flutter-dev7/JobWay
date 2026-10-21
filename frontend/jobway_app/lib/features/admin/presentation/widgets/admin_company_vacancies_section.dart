import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../domain/entities/admin_vacancy.dart';
import '../providers/admin_provider.dart';

class AdminCompanyVacanciesSection extends ConsumerStatefulWidget {
  final String companyId;

  const AdminCompanyVacanciesSection({super.key, required this.companyId});

  @override
  ConsumerState<AdminCompanyVacanciesSection> createState() =>
      _AdminCompanyVacanciesSectionState();
}

class _AdminCompanyVacanciesSectionState
    extends ConsumerState<AdminCompanyVacanciesSection> {
  static const _durations = [3, 7, 14, 30];
  static const _topColor = Color(0xFFD97706);

  String? _updatingId;

  String _daysLabel(int days) => days == 3 ? '3 дня' : '$days дней';

  Future<void> _promote(AdminVacancy vacancy) async {
    final days = await showCupertinoModalPopup<int>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(vacancy.title),
        message: Text(
          vacancy.isFeatured
              ? 'Сколько дней добавить к текущему продвижению?'
              : 'На сколько дней поднять вакансию в топ ленты?',
        ),
        actions: [
          ..._durations.map(
            (d) => CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(sheetContext, d),
              child: Text(_daysLabel(d)),
            ),
          ),
          if (vacancy.isFeatured)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(sheetContext, 0),
              child: const Text('Снять продвижение'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Отмена'),
        ),
      ),
    );

    if (days == null) return;
    await _apply(vacancy, days);
  }

  Future<void> _apply(AdminVacancy vacancy, int days) async {
    setState(() => _updatingId = vacancy.id);
    try {
      await ref.read(featureVacancyUseCaseProvider).call(vacancy.id, days: days);
      ref.invalidate(adminCompanyVacanciesProvider(widget.companyId));
      AppSnackbar.showSuccess(
        days == 0 ? 'Продвижение снято' : 'Вакансия продвигается',
      );
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  Widget _buildRow(AdminVacancy vacancy) {
    final colors = context.colors;
    final isUpdating = _updatingId == vacancy.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vacancy.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  vacancy.isFeatured
                      ? 'Топ до ${TimeAgo.formatDate(vacancy.featuredUntil!)}'
                      : 'Без продвижения',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: vacancy.isFeatured ? FontWeight.w600 : FontWeight.w400,
                    color: vacancy.isFeatured ? _topColor : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpdating)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: () => _promote(vacancy),
              style: TextButton.styleFrom(foregroundColor: context.accentColor),
              child: Text(vacancy.isFeatured ? 'Изменить' : 'Продвинуть'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final async = ref.watch(adminCompanyVacanciesProvider(widget.companyId));
    // При обновлении показываем предыдущий список, а не крутилку
    final vacancies = async.valueOrNull;

    Widget content;
    if (vacancies == null) {
      content = async.hasError
          ? Text(
              ApiException.extractMessage(async.error!),
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
    } else if (vacancies.isEmpty) {
      content = Text(
        'У компании нет активных вакансий. Продвигать можно только активные.',
        style: TextStyle(fontSize: 13, color: colors.textMuted),
      );
    } else {
      content = Column(
        children: [
          for (var i = 0; i < vacancies.length; i++) ...[
            if (i > 0) Divider(height: 1, color: colors.border),
            _buildRow(vacancies[i]),
          ],
        ],
      );
    }

    return SectionCard(
      title: 'Продвижение вакансий',
      icon: Icons.bolt_rounded,
      child: content,
    );
  }
}