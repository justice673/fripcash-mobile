import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

class AuthStepperStep {
  const AuthStepperStep({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
}

/// Horizontal numbered stepper (active = filled primary circle).
class AuthStepper extends StatelessWidget {
  const AuthStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<AuthStepperStep> steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  height: 1.5,
                  color: const Color(0xFFE0E0E0),
                ),
              ),
            ),
          _StepNode(
            index: i + 1,
            title: steps[i].title,
            subtitle: steps[i].subtitle,
            active: i == currentStep,
            completed: i < currentStep,
          ),
        ],
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.completed,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final emphasize = active || completed;
    final circleColor = emphasize ? AppColors.primary : Colors.white;
    final borderColor =
        emphasize ? AppColors.primary : const Color(0xFFD0D0D0);
    final numberColor = emphasize ? Colors.white : const Color(0xFFB0B0B0);
    final titleColor =
        emphasize ? AppColors.textPrimary : const Color(0xFF9E9E9E);
    final subtitleColor = const Color(0xFFB0B0B0);

    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: completed && !active
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$index',
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: numberColor,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}
