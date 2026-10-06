import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Seller score + review count — e.g. `4,8 (112)`.
class SellerRatingText extends StatelessWidget {
  const SellerRatingText({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w700,
  });

  final double rating;
  final int reviewCount;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final label = rating.toStringAsFixed(1).replaceAll('.', ',');
    return Text(
      '$label ($reviewCount)',
      style: AppTypography.style(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.primary,
      ),
    );
  }
}
