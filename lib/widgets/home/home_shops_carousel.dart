import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class HomeShopsCarousel extends StatelessWidget {
  const HomeShopsCarousel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.shops,
    this.topPadding = 28,
    this.onViewAll,
  });

  final String title;
  final String subtitle;
  final List<MockShop> shops;
  final double topPadding;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      t.viewAll,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const sidePad = 16.0;
              const gap = 12.0;
              const minCardWidth = 220.0;
              final available = constraints.maxWidth - sidePad * 2;
              final gaps = shops.length > 1 ? (shops.length - 1) * gap : 0.0;
              // Fit in one row when few shops and width allows; otherwise scroll.
              final fitsWithoutScroll = shops.length <= 3 &&
                  available >= shops.length * minCardWidth + gaps;

              if (fitsWithoutScroll) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: sidePad),
                  child: SizedBox(
                    height: 198,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < shops.length; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          Expanded(child: _ShopCard(shop: shops[i])),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 198,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: sidePad),
                  itemCount: shops.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: gap),
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 268,
                      child: _ShopCard(shop: shops[index]),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final MockShop shop;

  void _openShop(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(sellerId: shop.sellerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isPartner = shop.type == SellerType.enseigne;
    final deliveryLabel = isPartner
        ? t.partnerDeliveryWithin(shop.deliverySla)
        : t.sellerDeliversWithin(shop.deliverySla);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
          onTap: () => _openShop(context),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SafeNetworkImage(
                        url: shop.logoUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        iconSize: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 13,
                                color: Color(0xFFFFB800),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${shop.rating} (${shop.reviewCount})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            deliveryLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  shop.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openShop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 1.4,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      t.viewShop,
                      style: AppTypography.style(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
