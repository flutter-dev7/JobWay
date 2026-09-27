import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/reviews_provider.dart';

class ReviewBottomSheet extends ConsumerStatefulWidget {
  final String jobApplicationId;
  final String targetName;
  final VoidCallback onSubmitted;

  const ReviewBottomSheet({
    super.key,
    required this.jobApplicationId,
    required this.targetName,
    required this.onSubmitted,
  });

  static Future<void> show(
    BuildContext context, {
    required String jobApplicationId,
    required String targetName,
    required VoidCallback onSubmitted,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewBottomSheet(
        jobApplicationId: jobApplicationId,
        targetName: targetName,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      AppSnackbar.showError('Поставьте оценку от 1 до 5');
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(createReviewUseCaseProvider)
          .call(
            widget.jobApplicationId,
            _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        AppSnackbar.showSuccess('Отзыв отправлен');
        widget.onSubmitted();
      }
    } catch (error) {
      if (mounted) AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Оценить: ${widget.targetName}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 34,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Комментарий (необязательно)',
                hintStyle: TextStyle(color: colors.textMuted),
                filled: true,
                fillColor: colors.surfaceMuted,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Отправить',
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
