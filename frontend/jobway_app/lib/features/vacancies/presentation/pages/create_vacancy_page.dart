import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../skills/presentation/widgets/skills_selector.dart';
import '../providers/vacancies_provider.dart';

class CreateVacancyPage extends ConsumerStatefulWidget {
  const CreateVacancyPage({super.key});

  @override
  ConsumerState<CreateVacancyPage> createState() => _CreateVacancyPageState();
}

class _CreateVacancyPageState extends ConsumerState<CreateVacancyPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryFromController = TextEditingController();
  final _salaryToController = TextEditingController();
  String _employmentType = 'FullTime';
  String _experienceLevel = 'Junior';
  List<String> _selectedSkillIds = [];
  bool _isLoading = false;

  static const _employmentTypes = [
    'FullTime',
    'PartTime',
    'Remote',
    'Internship',
  ];
  static const _experienceLevels = [
    'NoExperience',
    'Junior',
    'Middle',
    'Senior',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryFromController.dispose();
    _salaryToController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      AppSnackbar.showError('Заполните название и описание');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(createVacancyUseCaseProvider)
          .call(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            employmentType: _employmentType,
            experienceLevel: _experienceLevel,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            salaryFrom: _salaryFromController.text.trim().isEmpty
                ? null
                : double.tryParse(_salaryFromController.text.trim()),
            salaryTo: _salaryToController.text.trim().isEmpty
                ? null
                : double.tryParse(_salaryToController.text.trim()),
            skillIds: _selectedSkillIds,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ref.invalidate(myVacanciesProvider);
      AppSnackbar.showSuccess('Вакансия создана как черновик');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Новая вакансия',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
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
                  icon: Icons.title,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Описание',
                  icon: Icons.notes_rounded,
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
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(employmentTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _employmentType = value!),
                  decoration: _dropdownDecoration(),
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  value: _experienceLevel,
                  items: _experienceLevels
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(experienceLevelLabel(level)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _experienceLevel = value!),
                  decoration: _dropdownDecoration(),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _locationController,
                  label: 'Локация',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _salaryFromController,
                        label: 'Зарплата от',
                        icon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _salaryToController,
                        label: 'Зарплата до',
                        icon: Icons.payments_outlined,
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
            label: 'Создать вакансию',
            isLoading: _isLoading,
            onPressed: _create,
          ),
        ],
      ),
    );
  }
}
