import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/theme/app_colors.dart';

class SellerTypeBadge extends StatelessWidget {
  const SellerTypeBadge({
    super.key,
    required this.type,
    this.compact = false,
  });

  final SellerType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sellerTypeLabel = switch (type) {
      SellerType.particulier => t.individualSellerRole,
      SellerType.boutique => t.shopRole,
      SellerType.enseigne => t.partnerBrandLabel,
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 10 : 6),
      ),
      child: Text(
        sellerTypeLabel,
        style: TextStyle(
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (stock > 5) return const SizedBox.shrink();

    final label = stock == 0 ? t.outOfStock : '${t.stock}: $stock';
    final color = stock == 0 ? Colors.red.shade600 : Colors.orange.shade800;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
