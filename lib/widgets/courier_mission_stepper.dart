import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/order_status_localization.dart';

enum CourierStepperAxis { vertical, horizontal }

/// Courier-facing subset of the order flow (collecte → livré).
class CourierMissionStepper extends StatelessWidget {
  const CourierMissionStepper({
    super.key,
    required this.currentStatus,
    this.axis = CourierStepperAxis.vertical,
  });

  final OrderStatus currentStatus;
  final CourierStepperAxis axis;

  static const _stepStatuses = <OrderStatus>[
    OrderStatus.readyForPickup,
    OrderStatus.collected,
    OrderStatus.inTransit,
    OrderStatus.delivered,
  ];

  int get _currentIndex {
    final index = currentStatus.index;
    if (index < OrderStatus.readyForPickup.index) return 0;
    if (index < OrderStatus.collected.index) return 0;
    if (index < OrderStatus.inTransit.index) return 1;
    if (index < OrderStatus.delivered.index) return 2;
    return 3;
  }

  String _stepLabel(OrderStatus status, AppLocalizations t) => switch (status) {
        OrderStatus.readyForPickup => t.courierStepToCollect,
        OrderStatus.collected => t.parcelCollected,
        OrderStatus.inTransit => t.courierStepInTransit,
        OrderStatus.delivered => t.delivered,
        _ => status.localizedLabel(t),
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final current = _currentIndex;

    if (axis == CourierStepperAxis.horizontal) {
      return _HorizontalTimeline(
        labels: _stepStatuses.map((s) => _stepLabel(s, t)).toList(),
        currentIndex: current,
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _stepStatuses.length; i++) ...[
          _StepRow(
            label: _stepLabel(_stepStatuses[i], t),
            state: i < current
                ? _StepState.done
                : i == current
                    ? _StepState.current
                    : _StepState.upcoming,
            isLast: i == _stepStatuses.length - 1,
          ),
        ],
      ],
    );
  }
}

class _HorizontalTimeline extends StatelessWidget {
  const _HorizontalTimeline({
    required this.labels,
    required this.currentIndex,
  });

  final List<String> labels;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 22),
                    color: i <= currentIndex
                        ? AppColors.primary
                        : Colors.grey.shade200,
                  ),
                ),
              _TimelineDot(
                state: i < currentIndex
                    ? _StepState.done
                    : i == currentIndex
                        ? _StepState.current
                        : _StepState.upcoming,
                label: labels[i],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({
    required this.state,
    required this.label,
  });

  final _StepState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _StepState.done;
    final isCurrent = state == _StepState.current;
    final color =
        isDone || isCurrent ? AppColors.primary : Colors.grey.shade300;

    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: isCurrent ? 34 : 26,
            height: isCurrent ? 34 : 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDone || isCurrent ? color : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : isCurrent
                    ? const Icon(
                        Icons.local_shipping_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              height: 1.15,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent
                  ? AppColors.textPrimary
                  : isDone
                      ? Colors.grey.shade700
                      : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.state,
    required this.isLast,
  });

  final String label;
  final _StepState state;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDone = state == _StepState.done;
    final isCurrent = state == _StepState.current;
    final dotColor =
        isDone || isCurrent ? AppColors.primary : Colors.grey.shade300;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 24 : 20,
                  height: isCurrent ? 24 : 20,
                  decoration: BoxDecoration(
                    color: isDone || isCurrent ? dotColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDone ? AppColors.primary : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isCurrent ? 17 : 15,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: isCurrent
                      ? AppColors.textPrimary
                      : isDone
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
