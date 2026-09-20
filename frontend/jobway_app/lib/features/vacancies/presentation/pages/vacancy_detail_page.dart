import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../../../applications/presentation/providers/applications_provider.dart';
import '../providers/vacancies_provider.dart';

class VacancyDetailPage extends ConsumerStatefulWidget {
  final String vacancyId;

  const VacancyDetailPage({super.key, required this.vacancyId});

  @override
  ConsumerState<VacancyDetailPage> createState() => _VacancyDetailPageState();
}

class _VacancyDetailPageState extends ConsumerState<VacancyDetailPage> {
  bool _isApplying = false;

  String _formatSalary(double? from, double? to) {
    if (from == null && to == null) return 'Не указана';
    if (from != null && to != null) return '${from.toStringAsFixed(0)} – ${to.toStringAsFixed(0)} TJS';
    if (from != null) return 'от ${from.toStringAsFixed(0)} TJS';
    return 'до ${to!.toStringAsFixed(0)} TJS';
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

  @override
  Widget build(BuildContext context) {
    final vacancyAsync = ref.watch(vacancyDetailProvider(widget.vacancyId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(backgroundColor: const Color(0xFFF7F8FA), surfaceTintColor: Colors.transparent, elevation: 0),
      body: vacancyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
        ),
        data: (vacancy) => Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              children: [
                Text(vacancy.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(vacancy.companyName, style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                const SizedBox(height: 20),
                SectionCard(
                  title: 'Детали',
                  icon: Icons.info_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailLine(label: 'Тип занятости', value: vacancy.employmentType),
                      const SizedBox(height: 10),
                      _DetailLine(label: 'Уровень опыта', value: vacancy.experienceLevel),
                      const SizedBox(height: 10),
                      _DetailLine(label: 'Локация', value: vacancy.location ?? 'Не указана'),
                      const SizedBox(height: 10),
                      _DetailLine(label: 'Зарплата', value: _formatSalary(vacancy.salaryFrom, vacancy.salaryTo)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Описание',
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
              child: AppButton(label: 'Откликнуться', isLoading: _isApplying, onPressed: _apply),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
      ],
    );
  }
}