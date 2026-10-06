import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/theme/app_colors.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.currentStatus});

  final OrderStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final steps = OrderStatus.timelineSteps;
    final currentIndex = currentStatus.isTerminalException
        ? -1
        : steps.indexOf(currentStatus);

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          _TimelineStep(
            label: steps[i].localizedLabel(t),
            state: currentIndex < 0
                ? _StepState.upcoming
                : i < currentIndex
                    ? _StepState.completed
                    : i == currentIndex
                        ? _StepState.current
                        : _StepState.upcoming,
            isLast: i == steps.length - 1,
          ),
        ],
      ],
    );
  }
}

enum _StepState { completed, current, upcoming }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.label,
    required this.state,
    required this.isLast,
  });

  final String label;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCompleted = state == _StepState.completed;
    final isCurrent = state == _StepState.current;

    final dotColor = isCompleted || isCurrent
        ? AppColors.primary
        : Colors.grey.shade300;
    final lineColor =
        isCompleted ? AppColors.primary : Colors.grey.shade200;
    final textColor = isCurrent
        ? AppColors.textPrimary
        : isCompleted
            ? Colors.grey.shade800
            : Colors.grey.shade500;
    final fontWeight =
        isCurrent ? FontWeight.w700 : FontWeight.w500;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 22 : 18,
                  height: isCurrent ? 22 : 18,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? dotColor
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isCurrent ? 3 : 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCurrent ? 15 : 14,
                  fontWeight: fontWeight,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
