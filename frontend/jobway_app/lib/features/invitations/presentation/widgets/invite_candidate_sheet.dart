import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_multiline_field.dart';
import '../../../subscription/domain/entities/subscription.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../../../vacancies/domain/entities/vacancy.dart';
import '../providers/invitations_provider.dart';

class InviteCandidateSheet extends ConsumerStatefulWidget {
  final String candidateProfileId;
  final String candidateName;

  const InviteCandidateSheet({
    super.key,
    required this.candidateProfileId,
    required this.candidateName,
  });

  static const maxMessageLength = 500;

  static Future<bool?> show(
    BuildContext context, {
    required String candidateProfileId,
    required String candidateName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InviteCandidateSheet(
        candidateProfileId: candidateProfileId,
        candidateName: candidateName,
      ),
    );
  }

  @override
  ConsumerState<InviteCandidateSheet> createState() => _InviteCandidateSheetState();
}

class _InviteCandidateSheetState extends ConsumerState<InviteCandidateSheet> {
  static const _red = Color(0xFFDC2626);

  final _messageController = TextEditingController();
  String? _pickedVacancyId;
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Подпись для вакансии, на которую приглашать нельзя
  static String? _blockedLabel(String? reason) {
    switch (reason) {
      case 'Applied':
        return 'Кандидат уже откликнулся';
      case 'Invited':
        return 'Приглашение отправлено, ждём ответа';
      case 'Declined':
        return 'Кандидат отклонил приглашение';
      default:
        return null;
    }
  }

  // Выбранная вакансия, если она ещё доступна. Единственная доступная выбирается сама
  String? _effectiveSelection(List<Vacancy> available) {
    final picked = _pickedVacancyId;
    if (picked != null && available.any((v) => v.id == picked)) return picked;
    return available.length == 1 ? available.first.id : null;
  }

  Future<void> _send(String? vacancyId) async {
    if (vacancyId == null) {
      setState(() => _error = 'Выберите вакансию');
      return;
    }

    final message = _messageController.text.trim();

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(inviteCandidateUseCaseProvider)
          .call(
            vacancyId: vacancyId,
            candidateProfileId: widget.candidateProfileId,
            message: message.isEmpty ? null : message,
          );
      // Счётчик приглашений в карточке тарифа и список недоступных вакансий
      ref.invalidate(subscriptionProvider);
      ref.invalidate(inviteBlockedProvider(widget.candidateProfileId));
      if (!mounted) return;
      Navigator.pop(context, true);
      AppSnackbar.showSuccess('Приглашение отправлено');
    } catch (error) {
      if (!mounted) return;
      // Ошибку показываем внутри окна: снекбар под ним не виден
      setState(() => _error = ApiException.extractMessage(error));
      // Данные могли устареть (например, кандидат только что откликнулся)
      ref.invalidate(inviteBlockedProvider(widget.candidateProfileId));
      ref.invalidate(subscriptionProvider);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNotice(String text, {Color? color, IconData icon = Icons.info_outline_rounded}) {
    final colors = context.colors;
    final tint = color ?? colors.textSecondary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, height: 1.4, color: tint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimit(Subscription? subscription) {
    if (subscription == null || subscription.invitationsLimit == 0) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final reached = subscription.isInvitationLimitReached;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        reached
            ? 'Лимит приглашений на сегодня исчерпан (${subscription.invitationsLimit})'
            : 'Сегодня осталось приглашений: ${subscription.invitationsLeft} из ${subscription.invitationsLimit}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
          color: reached ? _red : colors.textMuted,
        ),
      ),
    );
  }

  Widget _buildVacancies(
    List<Vacancy> vacancies,
    Map<String, String> blocked,
    String? selectedId,
  ) {
    return Column(
      children: vacancies.map((vacancy) {
        final label = _blockedLabel(blocked[vacancy.id]);

        return _VacancyOption(
          vacancy: vacancy,
          selected: selectedId == vacancy.id,
          blockedLabel: label,
          onTap: label != null || _isLoading
              ? null
              : () => setState(() {
                  _pickedVacancyId = vacancy.id;
                  _error = null;
                }),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    final colors = context.colors;
    final vacanciesAsync = ref.watch(inviteVacanciesProvider);
    final blockedAsync = ref.watch(inviteBlockedProvider(widget.candidateProfileId));
    final subscription = ref.watch(subscriptionProvider).valueOrNull;

    final vacancies = vacanciesAsync.valueOrNull;
    final blocked = blockedAsync.valueOrNull ?? const <String, String>{};

    if (vacanciesAsync.hasError && vacancies == null) {
      return _buildNotice(
        ApiException.extractMessage(vacanciesAsync.error!),
        color: _red,
        icon: Icons.error_outline_rounded,
      );
    }

    if (vacancies == null || (blockedAsync.isLoading && blockedAsync.valueOrNull == null)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vacancies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'У вас нет активных вакансий. Опубликуйте вакансию, чтобы приглашать кандидатов.',
          style: TextStyle(fontSize: 14, height: 1.5, color: colors.textSecondary),
        ),
      );
    }

    final available = vacancies.where((v) => !blocked.containsKey(v.id)).toList();
    final selectedId = _effectiveSelection(available);
    final limitReached = subscription?.isInvitationLimitReached ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'На какую вакансию?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        _buildLimit(subscription),
        const SizedBox(height: 10),
        _buildVacancies(vacancies, blocked, selectedId),
        if (available.isEmpty)
          _buildNotice(
            'Этого кандидата нельзя пригласить: он уже откликнулся или получил приглашение на все ваши активные вакансии.',
          )
        else ...[
          const SizedBox(height: 8),
          AppMultilineField(
            controller: _messageController,
            label: 'Сообщение (необязательно)',
            hint: 'Расскажите, чем вас заинтересовал этот кандидат',
            minLines: 3,
            maxLines: 5,
            maxLength: InviteCandidateSheet.maxMessageLength,
          ),
          if (_error != null)
            _buildNotice(_error!, color: _red, icon: Icons.error_outline_rounded),
          const SizedBox(height: 16),
          if (limitReached)
            AppButton(
              label: 'Лимит на сегодня исчерпан',
              icon: Icons.lock_outline_rounded,
              color: const Color(0xFF9CA3AF),
              onPressed: () {},
            )
          else
            AppButton(
              label: 'Отправить приглашение',
              isLoading: _isLoading,
              onPressed: () => _send(selectedId),
            ),
        ],
        // Ошибка при пустом списке доступных вакансий (редкий случай гонки)
        if (available.isEmpty && _error != null)
          _buildNotice(_error!, color: _red, icon: Icons.error_outline_rounded),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Пригласить кандидата',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.candidateName,
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
              const SizedBox(height: 18),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VacancyOption extends StatelessWidget {
  final Vacancy vacancy;
  final bool selected;
  final String? blockedLabel;
  final VoidCallback? onTap;

  const _VacancyOption({
    required this.vacancy,
    required this.selected,
    required this.blockedLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.accentColor;
    final blocked = blockedLabel != null;

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: blocked ? 0.55 : 1,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : colors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                blocked
                    ? Icons.block_rounded
                    : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? accent : colors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacancy.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (blocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          blockedLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      )
                    else if (vacancy.location != null && vacancy.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          vacancy.location!,
                          style: TextStyle(fontSize: 12, color: colors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}