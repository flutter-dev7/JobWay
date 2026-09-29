import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../skills/presentation/widgets/skills_selector.dart';
import '../../domain/entities/vacancy.dart';
import '../providers/vacancies_provider.dart';

class EditVacancyPage extends ConsumerStatefulWidget {
  final Vacancy vacancy;

  const EditVacancyPage({super.key, required this.vacancy});

  @override
  ConsumerState<EditVacancyPage> createState() => _EditVacancyPageState();
}

class _EditVacancyPageState extends ConsumerState<EditVacancyPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryFromController;
  late final TextEditingController _salaryToController;
  late String _employmentType;
  late String _experienceLevel;
  late String _paymentType;
  late String _currency;
  late List<String> _selectedSkillIds;
  bool _isLoading = false;

  static const _employmentTypes = ['FullTime', 'PartTime', 'Remote', 'Internship', 'Gig'];
  static const _experienceLevels = ['NoExperience', 'Junior', 'Middle', 'Senior'];
  static const _paymentTypes = ['Monthly', 'Daily', 'PerShift'];
  static const _currencies = ['TJS', 'USD', 'EUR', 'RUB'];

  @override
  void initState() {
    super.initState();
    final vacancy = widget.vacancy;
    _titleController = TextEditingController(text: vacancy.title);
    _descriptionController = TextEditingController(text: vacancy.description);
    _locationController = TextEditingController(text: vacancy.location ?? '');
    _salaryFromController = TextEditingController(
      text: vacancy.salaryFrom != null ? vacancy.salaryFrom!.toStringAsFixed(0) : '',
    );
    _salaryToController = TextEditingController(
      text: vacancy.salaryTo != null ? vacancy.salaryTo!.toStringAsFixed(0) : '',
    );
    _employmentType = vacancy.employmentType;
    _experienceLevel = vacancy.experienceLevel;
    _paymentType = vacancy.paymentType;
    _currency = vacancy.currency;
    _selectedSkillIds = vacancy.skills.map((s) => s.id).toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryFromController.dispose();
    _salaryToController.dispose();
    super.dispose();
  }

  InputDecoration _dropdownDecoration(BuildContext context) {
    final colors = context.colors;
    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: colors.border),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      AppSnackbar.showError('Введите название вакансии');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      AppSnackbar.showError('Добавьте описание вакансии');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(updateVacancyUseCaseProvider).call(
            widget.vacancy.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            employmentType: _employmentType,
            experienceLevel: _experienceLevel,
            paymentType: _paymentType,
            currency: _currency,
            location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
            salaryFrom: _salaryFromController.text.trim().isEmpty
                ? null
                : double.tryParse(_salaryFromController.text.trim()),
            salaryTo: _salaryToController.text.trim().isEmpty
                ? null
                : double.tryParse(_salaryToController.text.trim()),
            skillIds: _selectedSkillIds,
          );
      ref.invalidate(myVacanciesProvider);
      if (!mounted) return;
      context.pop();
      AppSnackbar.showSuccess('Вакансия обновлена');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Редактировать вакансию'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          SectionCard(
            title: 'Основное',
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'Название вакансии',
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Описание',
                  icon: Icons.notes_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _locationController,
                  label: 'Локация',
                  icon: Icons.location_on_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Условия',
            icon: Icons.tune_rounded,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  items: _employmentTypes
                      .map((type) => DropdownMenuItem(value: type, child: Text(employmentTypeLabel(type))))
                      .toList(),
                  onChanged: (value) => setState(() => _employmentType = value!),
                  decoration: _dropdownDecoration(context),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _experienceLevel,
                  items: _experienceLevels
                      .map((level) => DropdownMenuItem(value: level, child: Text(experienceLevelLabel(level))))
                      .toList(),
                  onChanged: (value) => setState(() => _experienceLevel = value!),
                  decoration: _dropdownDecoration(context),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _paymentType,
                        items: _paymentTypes
                            .map((type) => DropdownMenuItem(value: type, child: Text(paymentTypeLabel(type))))
                            .toList(),
                        onChanged: (value) => setState(() => _paymentType = value!),
                        decoration: _dropdownDecoration(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        items: _currencies
                            .map((c) => DropdownMenuItem(value: c, child: Text(currencyLabel(c))))
                            .toList(),
                        onChanged: (value) => setState(() => _currency = value!),
                        decoration: _dropdownDecoration(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _salaryFromController,
                        label: 'Зарплата от',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _salaryToController,
                        label: 'Зарплата до',
                        icon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Требуемые навыки',
            icon: Icons.auto_awesome_outlined,
            child: SkillsSelector(
              selectedSkillIds: _selectedSkillIds,
              onChanged: (ids) => setState(() => _selectedSkillIds = ids),
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Сохранить',
            isLoading: _isLoading,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}