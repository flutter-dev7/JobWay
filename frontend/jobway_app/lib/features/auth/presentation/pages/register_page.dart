import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobway_app/core/utils/image_utils.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/step_progress_bar.dart';
import '../../../candidate_profile/presentation/providers/candidate_profile_provider.dart';
import '../../../company_profile/presentation/providers/company_profile_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/register_steps/email_step.dart';
import '../widgets/register_steps/password_step.dart';
import '../widgets/register_steps/photo_step.dart';
import '../widgets/register_steps/role_name_step.dart';
import '../widgets/register_steps/verify_email_step.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  int _step = 0;
  static const _totalSteps = 5;

  String _role = 'Candidate';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  File? _pickedPhoto;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
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
      _emailController.text.trim().contains('@') &&
      _emailController.text.trim().contains('.');
  bool get _canContinueStep3 => _passwordController.text.length >= 6;

  void _next() => setState(() => _step++);
  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  void _continuePasswordStep() {
    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackbar.showError('Пароли не совпадают');
      return;
    }
    _next();
  }

  Future<void> _sendCode() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendRegistrationCode(_emailController.text.trim());
      if (mounted) _next();
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendRegistrationCode(_emailController.text.trim());
      AppSnackbar.showSuccess('Код отправлен повторно');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _verifyCode(String code) async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .verifyRegistrationCode(_emailController.text.trim(), code);
      if (mounted) _next();
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final source = await pickImageSourceDialog(context);
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      final file = await ImageUtils.ensureCompatibleFormat(File(picked.path));
      setState(() => _pickedPhoto = file);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            confirmPassword: _confirmPasswordController.text,
            role: _role,
            name: _nameController.text.trim(),
          );

      if (_pickedPhoto != null) {
        try {
          if (_role == 'Candidate') {
            await ref
                .read(uploadCandidatePhotoUseCaseProvider)
                .call(_pickedPhoto!);
          } else {
            await ref
                .read(uploadCompanyLogoUseCaseProvider)
                .call(_pickedPhoto!);
          }
        } catch (photoError) {
          AppSnackbar.showError(
            'Аккаунт создан, но фото не загрузилось: ${ApiException.extractMessage(photoError)}',
          );
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(role: result.role)),
      );
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: appMinimalAppBar(context, onBack: _back),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StepProgressBar(
                currentStep: _step,
                totalSteps: _totalSteps,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
        return RoleNameStep(
          role: _role,
          nameController: _nameController,
          onRoleChanged: (value) => setState(() => _role = value),
          canContinue: _canContinueStep0,
          onContinue: _next,
        );
      case 1:
        return EmailStep(
          emailController: _emailController,
          canContinue: _canContinueStep1,
          isLoading: _isLoading,
          onContinue: _sendCode,
        );
      case 2:
        return VerifyEmailStep(
          email: _emailController.text.trim(),
          onCodeCompleted: _verifyCode,
          isLoading: _isLoading,
          isResending: _isResending,
          onResend: _resendCode,
        );
      case 3:
        return PasswordStep(
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          canContinue: _canContinueStep3,
          onContinue: _continuePasswordStep,
        );
      default:
        return PhotoStep(
          role: _role,
          pickedPhoto: _pickedPhoto,
          isLoading: _isLoading,
          onPickPhoto: _pickPhoto,
          onSubmit: _submit,
        );
    }
  }
}
