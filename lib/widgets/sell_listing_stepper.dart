import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Compact 4-step progress: Catégorie → Photos → Détails → Prix.
class SellListingStepper extends StatelessWidget {
  const SellListingStepper({
    super.key,
    required this.currentStep,
    required this.labels,
  });

  final int currentStep;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    assert(labels.length == 4);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 18),
                  color: i <= currentStep
                      ? AppColors.primary.withValues(alpha: 0.45)
                      : const Color(0xFFE6DCD4),
                ),
              ),
            _SellStepNode(
              label: labels[i],
              active: i == currentStep,
              completed: i < currentStep,
            ),
          ],
        ],
      ),
    );
  }
}

class _SellStepNode extends StatelessWidget {
  const _SellStepNode({
    required this.label,
    required this.active,
    required this.completed,
  });

  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final on = active || completed;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: on ? AppColors.primary : const Color(0xFFD8CEC6),
              width: 1.5,
            ),
          ),
          child: on
              ? const Icon(Icons.check, size: 15, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.style(
            fontSize: 11,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            color: on
                ? AppColors.textPrimary
                : AppColors.textPrimary.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}
