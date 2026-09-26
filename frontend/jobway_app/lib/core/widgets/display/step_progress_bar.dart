import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: List.generate(totalSteps, (index) {
        final active = index <= currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: active ? colors.textPrimary : colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}