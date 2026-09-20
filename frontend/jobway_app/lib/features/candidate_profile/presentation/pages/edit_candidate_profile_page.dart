// features/candidate_profile/presentation/pages/edit_candidate_profile_page.dart — заменить целиком
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../skills/presentation/widgets/skills_selector.dart';
import '../../domain/entities/candidate_profile.dart';
import '../providers/candidate_profile_provider.dart';
import '../../../../core/widgets/section_card.dart';

class EditCandidateProfilePage extends ConsumerStatefulWidget {
  final CandidateProfile profile;

  const EditCandidateProfilePage({super.key, required this.profile});

  @override
  ConsumerState<EditCandidateProfilePage> createState() =>
      _EditCandidateProfilePageState();
}

class _EditCandidateProfilePageState
    extends ConsumerState<EditCandidateProfilePage> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _resumeUrlController;
  late final TextEditingController _birthDateController;
  late String _experienceLevel;
  late String _employmentType;
  late List<String> _selectedSkillIds;
  DateTime? _birthDate;
  bool _isLoading = false;

  static const _experienceLevels = [
    'NoExperience',
    'Junior',
    'Middle',
    'Senior',
  ];
  static const _employmentTypes = [
    'FullTime',
    'PartTime',
    'Remote',
    'Internship',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _resumeUrlController = TextEditingController(
      text: widget.profile.resumeFileUrl ?? '',
    );
    _experienceLevel = widget.profile.experienceLevel;
    _employmentType = widget.profile.desiredEmploymentType;
    _selectedSkillIds = widget.profile.skills.map((s) => s.id).toList();
    _birthDate = widget.profile.birthDate;
    _birthDateController = TextEditingController(text: _formatDate(_birthDate));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _resumeUrlController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_fullNameController.text.trim().isEmpty) {
      AppSnackbar.showError('Введите имя');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(updateCandidateProfileUseCaseProvider)
          .call(
            fullName: _fullNameController.text.trim(),
            birthDate: _birthDate,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            resumeFileUrl: _resumeUrlController.text.trim().isEmpty
                ? null
                : _resumeUrlController.text.trim(),
            experienceLevel: _experienceLevel,
            desiredEmploymentType: _employmentType,
            skillIds: _selectedSkillIds,
          );
      if (!mounted) return;
      Navigator.pop(context);
      AppSnackbar.showSuccess('Профиль обновлён');
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
          'Редактировать профиль',
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
            title: 'Основная информация',
            icon: Icons.person_outline_rounded,
            child: Column(
              children: [
                AppTextField(
                  controller: _fullNameController,
                  label: 'Имя и фамилия',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: AbsorbPointer(
                    child: AppTextField(
                      controller: _birthDateController,
                      label: 'Дата рождения',
                      icon: Icons.cake_outlined,
                    ),
                  ),
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
            title: 'О себе',
            icon: Icons.notes_rounded,
            child: Column(
              children: [
                AppTextField(
                  controller: _bioController,
                  label: 'Расскажите о себе',
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _resumeUrlController,
                  label: 'Ссылка на резюме',
                  icon: Icons.link,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Опыт и занятость',
            icon: Icons.work_outline_rounded,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _experienceLevel,
                  items: _experienceLevels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _experienceLevel = value!),
                  decoration: _dropdownDecoration(),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  items: _employmentTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _employmentType = value!),
                  decoration: _dropdownDecoration(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Навыки',
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
