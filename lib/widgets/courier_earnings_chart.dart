import 'package:flutter/material.dart';
import 'package:frip_cash/models/courier_earnings_week.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';

class CourierEarningsChart extends StatelessWidget {
  const CourierEarningsChart({
    super.key,
    required this.weeks,
  });

  final List<CourierEarningsWeek> weeks;

  @override
  Widget build(BuildContext context) {
    if (weeks.isEmpty) return const SizedBox.shrink();

    final maxAmount = weeks
        .map((week) => week.amountGnf)
        .reduce((a, b) => a > b ? a : b);
    final chartMax = maxAmount <= 0 ? 1 : (maxAmount * 1.15).round();

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AxisLabel(formatPrice(chartMax)),
                _AxisLabel(formatPrice((chartMax * 0.66).round())),
                _AxisLabel(formatPrice((chartMax * 0.33).round())),
                _AxisLabel('0'),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth / weeks.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          4,
                          (_) => Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < weeks.length; i++)
                          _BarColumn(
                            week: weeks[i],
                            chartMax: chartMax,
                            width: barWidth,
                            showMonthLabel: i == 1 || i == 3 || i == 5,
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 10,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.week,
    required this.chartMax,
    required this.width,
    required this.showMonthLabel,
  });

  final CourierEarningsWeek week;
  final int chartMax;
  final double width;
  final bool showMonthLabel;

  @override
  Widget build(BuildContext context) {
    final ratio = week.amountGnf / chartMax;
    final barHeight = (160 * ratio).clamp(8.0, 160.0);
    final monthLabel = _monthAbbreviation(week.label);

    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (week.highlighted)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    week.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${formatPrice(week.amountGnf)} GNF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: width * 0.42,
              height: barHeight,
              decoration: BoxDecoration(
                color: week.highlighted
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.35),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (showMonthLabel)
            Text(
              monthLabel,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  String _monthAbbreviation(String label) {
    final match = RegExp(
      r'([A-Za-zÀ-ÿ]{3,9})',
      caseSensitive: false,
    ).firstMatch(label);
    if (match == null) return '';
    final token = match.group(1)!;
    return token.length <= 4 ? token : token.substring(0, 3);
  }
}
