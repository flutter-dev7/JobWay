import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/features/applications/presentation/providers/applications_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/company_avatar.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/skill_chip.dart';
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

  String _formatSalary(double? from, double? to) {
    if (from == null && to == null) return 'Не указана';
    if (from != null && to != null) return '${from.toStringAsFixed(0)} – ${to.toStringAsFixed(0)} TJS';
    if (from != null) return 'от ${from.toStringAsFixed(0)} TJS';
    return 'до ${to!.toStringAsFixed(0)} TJS';
  }

  String _employmentTypeLabel(String type) {
    switch (type) {
      case 'FullTime':
        return 'Полная занятость';
      case 'PartTime':
        return 'Частичная занятость';
      case 'Remote':
        return 'Удалённо';
      case 'Internship':
        return 'Стажировка';
      default:
        return type;
    }
  }

  String _experienceLevelLabel(String level) {
    switch (level) {
      case 'NoExperience':
        return 'Без опыта';
      case 'Junior':
        return 'Junior';
      case 'Middle':
        return 'Middle';
      case 'Senior':
        return 'Senior';
      default:
        return level;
    }
  }

  Future<void> _apply() async {
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
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _share(Vacancy vacancy) {
    SharePlus.instance.share(ShareParams(
      text: '${vacancy.title} в ${vacancy.companyName}\n\nЗарплата: ${_formatSalary(vacancy.salaryFrom, vacancy.salaryTo)}\nЛокация: ${vacancy.location ?? "не указана"}\n\nНайдено в JobWay',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final vacancyAsync = ref.watch(vacancyDetailProvider(widget.vacancyId));
    final savedIds = ref.watch(savedVacancyIdsProvider);
    final isSaved = savedIds.contains(widget.vacancyId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Детали вакансии',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20, color: Color(0xFF111827)),
            onPressed: () {
              final vacancy = vacancyAsync.valueOrNull;
              if (vacancy != null) _share(vacancy);
            }, 
          ),
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 22,
              color: isSaved ? const Color(0xFF3157D5) : const Color(0xFF111827),
            ),
            onPressed: _isSaving ? null : () => _toggleSave(isSaved),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: vacancyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
        ),
        data: (vacancy) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
              children: [
                Row(
                  children: [
                    CompanyAvatar(companyName: vacancy.companyName, size: 52, logoUrl: vacancy.companyLogoUrl,),
                    const Spacer(),
                    if (vacancy.status == 'Active')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, size: 6, color: Color(0xFF059669)),
                            SizedBox(width: 6),
                            Text('Активно ищут', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(vacancy .title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    children: [
                      TextSpan(text: vacancy.companyName, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      if (vacancy.location != null) TextSpan(text: '  ·  📍 ${vacancy.location}'),
                      TextSpan(text: '  ·  Опубликовано ${TimeAgo.format(vacancy.createdAt)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Pill(label: _employmentTypeLabel(vacancy.employmentType)),
                    _Pill(label: _experienceLevelLabel(vacancy.experienceLevel)),
                  ],
                ),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'Обзор вакансии',
                  icon: Icons.dashboard_outlined,
                  child: Column(
                    children: [
                      _OverviewRow(icon: Icons.work_outline_rounded, label: 'Тип занятости', value: _employmentTypeLabel(vacancy.employmentType)),
                      const Divider(height: 24, color: Color(0xFFF3F4F6)),
                      _OverviewRow(icon: Icons.trending_up_rounded, label: 'Уровень опыта', value: _experienceLevelLabel(vacancy.experienceLevel)),
                      const Divider(height: 24, color: Color(0xFFF3F4F6)),
                      _OverviewRow(icon: Icons.location_on_outlined, label: 'Локация', value: vacancy.location ?? 'Не указана'),
                      const Divider(height: 24, color: Color(0xFFF3F4F6)),
                      _OverviewRow(
                        icon: Icons.payments_outlined,
                        label: 'Зарплата',
                        value: _formatSalary(vacancy.salaryFrom, vacancy.salaryTo),
                        valueColor: const Color(0xFF3157D5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'О вакансии',
                  icon: Icons.notes_rounded,
                  child: Text(vacancy.description, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF4B5563))),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Требуемые навыки',
                  icon: Icons.auto_awesome_outlined,
                  child: vacancy.skills.isEmpty
                      ? const Text('Не указаны', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)))
                      : Wrap(spacing: 8, runSpacing: 10, children: vacancy.skills.map((s) => SkillChip(label: s.nameRu)).toList()),
                ),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isSaved ? const Color(0xFF3157D5) : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Откликнуться',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isApplying,
                      onPressed: _apply,
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

class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _OverviewRow({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        ),
        Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? const Color(0xFF111827))),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
    );
  }
}