import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../skills/presentation/widgets/skills_selector.dart';
import '../../domain/entities/candidate_profile.dart';
import '../providers/candidate_profile_provider.dart';

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
  late final TextEditingController _birthDateController;
  late String _experienceLevel;
  late String _employmentType;
  late List<String> _selectedSkillIds;
  late String? _resumeFileUrl;
  DateTime? _birthDate;
  bool _isLoading = false;
  bool _isUploadingResume = false;

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
    _experienceLevel = widget.profile.experienceLevel;
    _employmentType = widget.profile.desiredEmploymentType;
    _selectedSkillIds = widget.profile.skills.map((s) => s.id).toList();
    _birthDate = widget.profile.birthDate;
    _birthDateController = TextEditingController(text: _formatDate(_birthDate));
    _resumeFileUrl = widget.profile.resumeFileUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
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

  Future<void> _pickAndUploadResume() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (file == null || file.path == null) return;

    final selectedFile = File(file.path!);

    setState(() => _isUploadingResume = true);

    try {
      await ref.read(uploadResumeUseCaseProvider).call(selectedFile);
      ref.invalidate(candidateProfileProvider);
      AppSnackbar.showSuccess('Резюме загружено');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isUploadingResume = false);
      }
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
            resumeFileUrl: _resumeFileUrl,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Редактировать профиль'),
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
            child: AppTextField(
              controller: _bioController,
              label: 'Расскажите о себе',
              icon: Icons.info_outline,
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
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(experienceLevelLabel(level)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _experienceLevel = value!),
                  decoration: _dropdownDecoration(context),
                ),
                const SizedBox(height: 14),
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
                  decoration: _dropdownDecoration(context),
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
          const SizedBox(height: 16),
          SectionCard(
            title: 'Резюме',
            icon: Icons.attach_file_rounded,
            child: _resumeFileUrl == null || _resumeFileUrl!.isEmpty
                ? AppButton(
                    label: 'Загрузить резюме',
                    icon: Icons.upload_file_outlined,
                    isLoading: _isUploadingResume,
                    onPressed: _pickAndUploadResume,
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 20,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _resumeFileUrl!.split('/').last,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _isUploadingResume
                              ? null
                              : _pickAndUploadResume,
                          icon: _isUploadingResume
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Заменить файл'),
                          style: TextButton.styleFrom(
                            foregroundColor: context.accentColor,
                          ),
                        ),
                      ),
                    ],
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
