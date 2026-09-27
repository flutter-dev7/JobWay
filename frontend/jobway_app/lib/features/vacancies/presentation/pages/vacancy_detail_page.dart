import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import 'package:jobway_app/features/applications/presentation/providers/applications_provider.dart';
import 'package:jobway_app/features/review/presentation/widgets/reviews_section.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../../core/widgets/display/info_row.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/display/skill_chip.dart';
import '../../domain/entities/vacancy.dart';
import '../providers/vacancies_provider.dart';

class VacancyDetailPage extends ConsumerStatefulWidget {
  final String vacancyId;

  const VacancyDetailPage({super.key, required this.vacancyId});

  @override
  ConsumerState<VacancyDetailPage> createState() => _VacancyDetailPageState();
}

class _VacancyDetailPageState extends ConsumerState<VacancyDetailPage> {
  bool _isApplying = false;
  bool _isSaving = false;

  String _formatSalary(
    double? from,
    double? to,
    String paymentType,
    String currency,
  ) {
    if (from == null && to == null) return 'Не указана';
    final currencyLabelText = currencyLabel(currency);
    final suffix = paymentTypeLabel(paymentType);
    if (from != null && to != null) {
      return '${from.toStringAsFixed(0)} – ${to.toStringAsFixed(0)} $currencyLabelText $suffix';
    }
    if (from != null)
      return 'от ${from.toStringAsFixed(0)} $currencyLabelText $suffix';
    return 'до ${to!.toStringAsFixed(0)} $currencyLabelText $suffix';
  }

  Future<void> _apply(bool hasApplied) async {
    if (_isApplying || hasApplied) return;

    setState(() => _isApplying = true);
    try {
      await ref.read(applyToVacancyUseCaseProvider).call(widget.vacancyId);
      if (!mounted) return;
      AppSnackbar.showSuccess('Отклик отправлен');
      ref.invalidate(myApplicationsProvider);
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  Future<void> _toggleSave(bool isSaved) async {
    setState(() => _isSaving = true);
    final notifier = ref.read(savedVacancyIdsProvider.notifier);
    try {
      if (isSaved) {
        await ref.read(unsaveVacancyUseCaseProvider).call(widget.vacancyId);
        notifier.update((state) => {...state}..remove(widget.vacancyId));
      } else {
        await ref.read(saveVacancyUseCaseProvider).call(widget.vacancyId);
        notifier.update((state) => {...state, widget.vacancyId});
      }
      ref.invalidate(savedVacanciesProvider);
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _share(Vacancy vacancy) {
    SharePlus.instance.share(
      ShareParams(
        text:
            '${vacancy.title} в ${vacancy.companyName}\n\nЗарплата: ${_formatSalary(vacancy.salaryFrom, vacancy.salaryTo, vacancy.paymentType, vacancy.currency)}\nЛокация: ${vacancy.location ?? "не указана"}\n\nНайдено в JobWay',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vacancyAsync = ref.watch(vacancyDetailProvider(widget.vacancyId));
    final savedIds = ref.watch(savedVacancyIdsProvider);
    final isSaved = savedIds.contains(widget.vacancyId);
    final appliedIds = ref.watch(appliedVacancyIdsProvider);
    final hasApplied = appliedIds.contains(widget.vacancyId);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(
        context,
        'Детали вакансии',
        actions: [
          IconButton(
            icon: Icon(Icons.share, size: 20, color: colors.textPrimary),
            onPressed: () {
              final vacancy = vacancyAsync.valueOrNull;
              if (vacancy != null) _share(vacancy);
            },
          ),
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 22,
              color: isSaved ? context.accentColor : colors.textPrimary,
            ),
            onPressed: _isSaving ? null : () => _toggleSave(isSaved),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vacancyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (vacancy) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
              children: [
                Row(
                  children: [
                    CompanyAvatar(
                      companyName: vacancy.companyName,
                      size: 52,
                      logoUrl: vacancy.companyLogoUrl,
                    ),
                    const Spacer(),
                    if (vacancy.status == 'Active')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: Color(0xFF059669),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Активно ищут',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  vacancy.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                    children: [
                      TextSpan(
                        text: vacancy.companyName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (vacancy.location != null)
                        TextSpan(text: '  ·  📍 ${vacancy.location}'),
                      TextSpan(
                        text:
                            '  ·  Опубликовано ${TimeAgo.format(vacancy.createdAt)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(label: employmentTypeLabel(vacancy.employmentType)),
                    _Pill(label: experienceLevelLabel(vacancy.experienceLevel)),
                  ],
                ),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'Обзор вакансии',
                  icon: Icons.dashboard_outlined,
                  child: Column(
                    children: [
                      InfoOverviewRow(
                        icon: Icons.work_outline_rounded,
                        label: 'Тип занятости',
                        value: employmentTypeLabel(vacancy.employmentType),
                      ),
                      Divider(height: 24, color: colors.border),
                      InfoOverviewRow(
                        icon: Icons.trending_up_rounded,
                        label: 'Уровень опыта',
                        value: experienceLevelLabel(vacancy.experienceLevel),
                      ),
                      Divider(height: 24, color: colors.border),
                      InfoOverviewRow(
                        icon: Icons.location_on_outlined,
                        label: 'Локация',
                        value: vacancy.location ?? 'Не указана',
                      ),
                      Divider(height: 24, color: colors.border),
                      InfoOverviewRow(
                        icon: Icons.payments_outlined,
                        label: 'Зарплата',
                        value: _formatSalary(
                          vacancy.salaryFrom,
                          vacancy.salaryTo,
                          vacancy.paymentType,
                          vacancy.currency,
                        ),
                        valueColor: context.accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'О вакансии',
                  icon: Icons.notes_rounded,
                  child: Text(
                    vacancy.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Требуемые навыки',
                  icon: Icons.auto_awesome_outlined,
                  child: vacancy.skills.isEmpty
                      ? Text(
                          'Не указаны',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textMuted,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: vacancy.skills
                              .map((s) => SkillChip(label: s.nameRu))
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                ReviewsSection(userId: vacancy.companyUserId),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isSaving ? null : () => _toggleSave(isSaved),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved
                            ? context.accentColor
                            : colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: hasApplied
                        ? AppButton(
                            label: 'Вы откликнулись',
                            icon: Icons.check_rounded,
                            color: const Color(0xFF9CA3AF),
                            onPressed: () {},
                          )
                        : AppButton(
                            label: 'Откликнуться',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: _isApplying,
                            onPressed: () => _apply(hasApplied),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
