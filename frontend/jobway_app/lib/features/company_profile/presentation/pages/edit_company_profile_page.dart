// features/company_profile/presentation/pages/edit_company_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/widgets/inputs/app_multiline_field.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../domain/entities/company_profile.dart';
import '../providers/company_profile_provider.dart';

class EditCompanyProfilePage extends ConsumerStatefulWidget {
  final CompanyProfile profile;

  const EditCompanyProfilePage({super.key, required this.profile});

  @override
  ConsumerState<EditCompanyProfilePage> createState() =>
      _EditCompanyProfilePageState();
}

class _EditCompanyProfilePageState
    extends ConsumerState<EditCompanyProfilePage> {
  late final TextEditingController _companyNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _industryController;
  late final TextEditingController _websiteController;
  late final TextEditingController _locationController;
  late final TextEditingController _phoneController;
  late final TextEditingController _telegramController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(
      text: widget.profile.companyName,
    );
    _descriptionController = TextEditingController(
      text: widget.profile.description ?? '',
    );
    _industryController = TextEditingController(
      text: widget.profile.industry ?? '',
    );
    _websiteController = TextEditingController(
      text: widget.profile.website ?? '',
    );
    _locationController = TextEditingController(
      text: widget.profile.location ?? '',
    );
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
    _telegramController = TextEditingController(
      text: widget.profile.telegramUsername ?? '',
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _descriptionController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  String? _valueOrNull(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (_companyNameController.text.trim().isEmpty) {
      AppSnackbar.showError('Введите название компании');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(updateCompanyProfileUseCaseProvider)
          .call(
            companyName: _companyNameController.text.trim(),
            description: _valueOrNull(_descriptionController),
            industry: _valueOrNull(_industryController),
            website: _valueOrNull(_websiteController),
            location: _valueOrNull(_locationController),
            phone: _valueOrNull(_phoneController),
            telegramUsername: _valueOrNull(_telegramController),
          );
      if (!mounted) return;
      context.pop();
      AppSnackbar.showSuccess('Профиль компании обновлён');
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
      appBar: appPageAppBar(context, 'Редактировать компанию'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          SectionCard(
            title: 'Основная информация',
            icon: Icons.business_outlined,
            child: Column(
              children: [
                AppTextField(
                  controller: _companyNameController,
                  label: 'Название компании',
                  icon: Icons.business_rounded,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _industryController,
                  label: 'Индустрия',
                  icon: Icons.category_outlined,
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
            title: 'О компании',
            icon: Icons.notes_rounded,
            child: Column(
              children: [
                AppMultilineField(
                  controller: _descriptionController,
                  label: 'Описание',
                  hint:
                      'Чем занимается компания, сколько человек в команде, что для вас важно',
                  minLines: 6,
                  maxLines: 12,
                  maxLength: 2000,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _websiteController,
                  label: 'Сайт',
                  icon: Icons.link,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Контакты',
            icon: Icons.support_agent_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'Кандидаты увидят эти контакты на странице ваших вакансий. '
                    'Телефон укажите в международном формате (+992…), '
                    'Telegram без значка @.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                AppTextField(
                  controller: _phoneController,
                  label: 'Телефон',
                  icon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _telegramController,
                  label: 'Telegram',
                  icon: Icons.send_rounded,
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