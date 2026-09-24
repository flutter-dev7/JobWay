// features/auth/presentation/pages/register_page.dart — заменить целиком
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../candidate_profile/presentation/providers/candidate_profile_provider.dart';
import '../../../company_profile/presentation/providers/company_profile_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_selector.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  int _step = 0;
  static const _totalSteps = 4;

  String _role = 'Candidate';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _pickedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // подписываемся на изменения текста, чтобы кнопка "Продолжить" реагировала на каждый ввод
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canContinueStep0 => _nameController.text.trim().isNotEmpty;
  bool get _canContinueStep1 =>
      _emailController.text.trim().contains('@') && _emailController.text.trim().contains('.');
  bool get _canContinueStep2 =>
      _passwordController.text.length >= 6 && _passwordController.text == _confirmPasswordController.text;

  void _next() {
    if (_step < _totalSteps - 1) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickPhoto() async {
    final source = await pickImageSourceDialog(context);
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null) setState(() => _pickedPhoto = File(picked.path));
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authRepositoryProvider).register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            role: _role,
            name: _nameController.text.trim(),
          );

      if (_pickedPhoto != null) {
        try {
          if (_role == 'Candidate') {
            await ref.read(uploadCandidatePhotoUseCaseProvider).call(_pickedPhoto!);
          } else {
            await ref.read(uploadCompanyLogoUseCaseProvider).call(_pickedPhoto!);
          }
        } catch (_) {
          // фото не критично для успешной регистрации — не блокируем вход из-за него
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(role: result.role)));
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF111827)), onPressed: _back),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_totalSteps, (index) {
                  final active = index <= _step;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == _totalSteps - 1 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: _buildStep(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step0RoleAndName(
          role: _role,
          nameController: _nameController,
          onRoleChanged: (value) => setState(() => _role = value),
          canContinue: _canContinueStep0,
          onContinue: _next,
        );
      case 1:
        return _Step1Email(
          emailController: _emailController,
          canContinue: _canContinueStep1,
          onContinue: _next,
        );
      case 2:
        return _Step2Password(
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          canContinue: _canContinueStep2,
          onContinue: _next,
        );
      default:
        return _Step3Photo(
          role: _role,
          pickedPhoto: _pickedPhoto,
          isLoading: _isLoading,
          onPickPhoto: _pickPhoto,
          onSubmit: _submit,
        );
    }
  }
}

class _Step0RoleAndName extends StatelessWidget {
  final String role;
  final TextEditingController nameController;
  final ValueChanged<String> onRoleChanged;
  final bool canContinue;
  final VoidCallback onContinue;

  const _Step0RoleAndName({
    required this.role,
    required this.nameController,
    required this.onRoleChanged,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Кто вы?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Выберите роль и представьтесь', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        RoleSelector(selectedRole: role, onChanged: onRoleChanged),
        const SizedBox(height: 18),
        AppTextField(
          controller: nameController,
          label: role == 'Candidate' ? 'Имя и фамилия' : 'Название компании',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 28),
        AppButton(label: 'Продолжить', onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}

class _Step1Email extends StatelessWidget {
  final TextEditingController emailController;
  final bool canContinue;
  final VoidCallback onContinue;

  const _Step1Email({required this.emailController, required this.canContinue, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Ваш email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Понадобится для входа в аккаунт', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        AppTextField(
          controller: emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        AppButton(label: 'Продолжить', onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}

class _Step2Password extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool canContinue;
  final VoidCallback onContinue;

  const _Step2Password({
    required this.passwordController,
    required this.confirmPasswordController,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Придумайте пароль', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Минимум 6 символов', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 28),
        AppTextField(controller: passwordController, label: 'Пароль', icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 14),
        AppTextField(controller: confirmPasswordController, label: 'Повторите пароль', icon: Icons.lock_outline, isPassword: true),
        const SizedBox(height: 28),
        AppButton(label: 'Продолжить', onPressed: canContinue ? onContinue : null),
      ],
    );
  }
}

class _Step3Photo extends StatelessWidget {
  final String role;
  final File? pickedPhoto;
  final bool isLoading;
  final VoidCallback onPickPhoto;
  final VoidCallback onSubmit;

  const _Step3Photo({
    required this.role,
    required this.pickedPhoto,
    required this.isLoading,
    required this.onPickPhoto,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(role == 'Candidate' ? 'Добавьте фото профиля' : 'Добавьте лого компании',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        const SizedBox(height: 6),
        const Text('Необязательно — можно добавить позже в профиле', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: pickedPhoto != null
                ? ClipOval(child: Image.file(pickedPhoto!, width: 120, height: 120, fit: BoxFit.cover))
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF3157D5), width: 2),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, size: 32, color: Color(0xFF3157D5)),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: Text(
              pickedPhoto != null ? 'Изменить фото' : 'Нажмите, чтобы добавить фото',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3157D5)),
            ),
          ),
        ),
        const SizedBox(height: 40),
        AppButton(label: 'Завершить регистрацию', isLoading: isLoading, onPressed: onSubmit),
      ],
    );
  }
}