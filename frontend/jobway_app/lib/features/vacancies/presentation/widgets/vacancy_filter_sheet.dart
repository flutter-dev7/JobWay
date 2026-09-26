// features/vacancies/presentation/widgets/vacancy_filter_sheet.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../domain/entities/vacancy_filter.dart';

class VacancyFilterSheet extends StatefulWidget {
  final VacancyFilter currentFilter;
  final ValueChanged<VacancyFilter> onApply;

  const VacancyFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<VacancyFilterSheet> createState() => _VacancyFilterSheetState();
}

class _VacancyFilterSheetState extends State<VacancyFilterSheet> {
  String? _employmentType;
  String? _experienceLevel;
  final _locationController = TextEditingController();
  final _salaryFromController = TextEditingController();

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
  void initState() {
    super.initState();
    _employmentType = widget.currentFilter.employmentType;
    _experienceLevel = widget.currentFilter.experienceLevel;
    _locationController.text = widget.currentFilter.location ?? '';
    _salaryFromController.text = widget.currentFilter.salaryFrom != null
        ? widget.currentFilter.salaryFrom!.toStringAsFixed(0)
        : '';
  }

  @override
  void dispose() {
    _locationController.dispose();
    _salaryFromController.dispose();
    super.dispose();
  }

  Widget _buildChips(
    List<String> options,
    String? selected,
    ValueChanged<String?> onSelect,
    String Function(String) labelBuilder,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;

        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelBuilder(option),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _clearAll() {
    setState(() {
      _employmentType = null;
      _experienceLevel = null;
      _locationController.clear();
      _salaryFromController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Фильтры',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                  ),
                  child: const Text('Сбросить'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Тип занятости',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            _buildChips(
              _employmentTypes,
              _employmentType,
              (value) => setState(() => _employmentType = value),
              employmentTypeLabel,
            ),

            const SizedBox(height: 18),

            const Text(
              'Уровень опыта',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 8),

            _buildChips(
              _experienceLevels,
              _experienceLevel,
              (value) => setState(() => _experienceLevel = value),
              experienceLevelLabel,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _locationController,
              label: 'Локация',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _salaryFromController,
              label: 'Зарплата от',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Применить',
              onPressed: () {
                final location = _locationController.text.trim();
                final salaryFrom = _salaryFromController.text.trim();

                widget.onApply(
                  widget.currentFilter.copyWith(
                    employmentType: _employmentType,
                    clearEmploymentType: _employmentType == null,
                    experienceLevel: _experienceLevel,
                    clearExperienceLevel: _experienceLevel == null,
                    location: location.isEmpty ? null : location,
                    clearLocation: location.isEmpty,
                    salaryFrom: salaryFrom.isEmpty
                        ? null
                        : double.tryParse(salaryFrom),
                    clearSalaryFrom: salaryFrom.isEmpty,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
