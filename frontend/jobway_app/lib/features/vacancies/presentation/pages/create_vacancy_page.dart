import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_multiline_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../skills/presentation/widgets/skills_selector.dart';
import '../../domain/vacancy_form_rules.dart';
import '../providers/vacancies_provider.dart';

class CreateVacancyPage extends ConsumerStatefulWidget {
  const CreateVacancyPage({super.key});

  @override
  ConsumerState<CreateVacancyPage> createState() => _CreateVacancyPageState();
}

class _CreateVacancyPageState extends ConsumerState<CreateVacancyPage> {
  static const _stepCount = 4;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryFromController = TextEditingController();
  final _salaryToController = TextEditingController();
  final _scrollController = ScrollController();

  String _employmentType = 'FullTime';
  String _experienceLevel = 'Junior';
  String _paymentType = 'Monthly';
  String _currency = 'TJS';
  List<String> _selectedSkillIds = [];

  int _step = 0;
  String? _stepError;
  bool _isLoading = false;

  static const _employmentTypes = [
    'FullTime',
    'PartTime',
    'Remote',
    'Internship',
    'Gig',
  ];
  static const _experienceLevels = [
    'NoExperience',
    'Junior',
    'Middle',
    'Senior',
  ];
  static const _paymentTypes = ['Monthly', 'Daily', 'PerShift'];
  static const _currencies = ['TJS', 'USD', 'EUR', 'RUB'];

  bool get _isLastStep => _step == _stepCount - 1;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    _salaryFromController.dispose();
    _salaryToController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Возвращает текст ошибки для шага или null, если всё заполнено
  String? _validateStep(int step) {
    switch (step) {
      case 0:
        return VacancyFormRules.validateMain(
          title: _titleController.text,
          description: _descriptionController.text,
        );
      case 1:
        return VacancyFormRules.validateDuties(
          responsibilities: _responsibilitiesController.text,
          requirements: _requirementsController.text,
        );
      case 2:
        return VacancyFormRules.validateConditions(
          location: _locationController.text,
          salaryFrom: _salaryFromController.text,
          salaryTo: _salaryToController.text,
        );
      default:
        return VacancyFormRules.validateSkills(_selectedSkillIds.length);
    }
  }

  void _goToStep(int step) {
    setState(() {
      _step = step;
      _stepError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
    });
  }

  void _next() {
    final error = _validateStep(_step);
    if (error != null) {
      setState(() => _stepError = error);
      return;
    }
    _goToStep(_step + 1);
  }

  void _back() {
    if (_step > 0) _goToStep(_step - 1);
  }

  Future<void> _create() async {
    // Проверяем все шаги: если ошибка на раннем шаге, возвращаем туда
    for (var step = 0; step < _stepCount; step++) {
      final error = _validateStep(step);
      if (error != null) {
        _goToStep(step);
        setState(() => _stepError = error);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(createVacancyUseCaseProvider)
          .call(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            responsibilities: _responsibilitiesController.text.trim(),
            requirements: _requirementsController.text.trim(),
            employmentType: _employmentType,
            experienceLevel: _experienceLevel,
            paymentType: _paymentType,
            currency: _currency,
            location: _locationController.text.trim(),
            salaryFrom: VacancyFormRules.parseMoney(_salaryFromController.text),
            salaryTo: VacancyFormRules.parseMoney(_salaryToController.text),
            skillIds: _selectedSkillIds,
          );
      if (!mounted) return;
      context.pop();
      AppSnackbar.showSuccess('Вакансия создана как черновик');
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

  // Только полоски прогресса, без подписей шагов
  Widget _buildProgress() {
    final colors = context.colors;

    return Row(
      children: List.generate(_stepCount, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < _stepCount - 1 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _step ? context.accentColor : colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHint(String text) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, height: 1.5, color: colors.textSecondary),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return SectionCard(
          title: 'Основное',
          icon: LucideIcons.briefcase,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHint(
                'Назовите должность так, как её ищут кандидаты, и коротко '
                'расскажите о вакансии.',
              ),
              AppTextField(
                controller: _titleController,
                label: 'Название вакансии',
                icon: Icons.title,
              ),
              const SizedBox(height: 14),
              AppMultilineField(
                controller: _descriptionController,
                label: 'Описание',
                hint: 'Чем занимается компания, какая команда, что предстоит делать',
                minLines: 5,
                maxLines: 10,
                maxLength: VacancyFormRules.maxDescriptionLength,
              ),
            ],
          ),
        );
      case 1:
        return SectionCard(
          title: 'Обязанности и требования',
          icon: Icons.checklist_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHint('Пишите каждый пункт с новой строки, они отобразятся списком.'),
              AppMultilineField(
                controller: _responsibilitiesController,
                label: 'Обязанности',
                hint: 'Принимать заказы\nКонсультировать покупателей\nВести кассу',
                minLines: 5,
                maxLines: 10,
                maxLength: VacancyFormRules.maxListLength,
              ),
              const SizedBox(height: 14),
              AppMultilineField(
                controller: _requirementsController,
                label: 'Требования',
                hint: 'Опыт от 1 года\nОтветственность\nУмение работать в команде',
                minLines: 5,
                maxLines: 10,
                maxLength: VacancyFormRules.maxListLength,
              ),
            ],
          ),
        );
      case 2:
        return SectionCard(
          title: 'Условия',
          icon: Icons.tune_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHint('Укажите место работы и хотя бы одну границу зарплаты.'),
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
                onChanged: (value) => setState(() => _employmentType = value!),
                decoration: _dropdownDecoration(context),
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
                onChanged: (value) => setState(() => _experienceLevel = value!),
                decoration: _dropdownDecoration(context),
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
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _paymentType,
                items: _paymentTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text('Оплата ${paymentTypeLabel(type)}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _paymentType = value!),
                decoration: _dropdownDecoration(context),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _currency,
                items: _currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _currency = value!),
                decoration: _dropdownDecoration(context),
              ),
            ],
          ),
        );
      default:
        return SectionCard(
          title: 'Требуемые навыки',
          icon: Icons.auto_awesome_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHint(
                'Выберите навыки, которые нужны кандидату. По ним считается '
                'совпадение с резюме. Минимум один, не больше '
                '${VacancyFormRules.maxSkills}.',
              ),
              SkillsSelector(
                selectedSkillIds: _selectedSkillIds,
                onChanged: (ids) => setState(() {
                  _selectedSkillIds = ids;
                  _stepError = null;
                }),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildError() {
    const color = Color(0xFFDC2626);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _stepError!,
              style: const TextStyle(fontSize: 13, height: 1.4, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final colors = context.colors;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            if (_step > 0) ...[
              SizedBox(
                width: 110,
                height: 52,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _back,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Назад',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: AppButton(
                label: _isLastStep ? 'Создать вакансию' : 'Далее',
                isLoading: _isLoading,
                onPressed: _isLastStep ? _create : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: appPageAppBar(context, 'Новая вакансия'),
        body: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _buildProgress(),
            const SizedBox(height: 20),
            _buildStepContent(),
            if (_stepError != null) _buildError(),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}