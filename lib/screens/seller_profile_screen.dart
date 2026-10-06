import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/share_links.dart';
import 'package:frip_cash/widgets/follow_button.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_type_badge.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seller = sellerById(sellerId);
    if (seller == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(t.sellerNotFound)),
      );
    }

    final listings = ListingsRepository.instance.allCached
        .where((product) => product.sellerId == sellerId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          seller.username,
          style: AppTypography.style(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: t.share,
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () {
              shareShop(
                context,
                sellerId: sellerId,
                shopName: seller.username,
                publicUrl: null,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SafeNetworkImage(
                  url: seller.avatarUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  iconSize: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller.username,
                      style: AppTypography.style(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SellerTypeBadge(type: seller.type, compact: true),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < seller.rating.round();
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            size: 16,
                            color: const Color(0xFFFFB800),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          t.reviewsCount(seller.reviewCount),
                          style: AppTypography.style(fontSize: 13),
                        ),
                      ],
                    ),
                    if (seller.badge != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '+ ${seller.badge!}',
                          style: AppTypography.style(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FollowButton(sellerId: seller.id, fullWidth: true),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                t.listingsCount(listings.length),
                style: AppTypography.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(Icons.tune, size: 18, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                t.filterTitle,
                style: AppTypography.style(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (listings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                t.noPublicListings,
                textAlign: TextAlign.center,
                style: AppTypography.style(),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    AppBreakpoints.productGridCrossAxisCount(context),
                crossAxisSpacing: 12,
                mainAxisSpacing:
                    AppBreakpoints.productGridMainAxisSpacing(context),
                childAspectRatio:
                    AppBreakpoints.productGridChildAspectRatio(context),
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                return _SellerListingCard(
                  product: listings[index],
                  onTap: () => openProductDetail(context, listings[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SellerListingCard extends StatelessWidget {
  const _SellerListingCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sizeLabel = product.size.toLowerCase() == 'unique'
        ? t.oneSize
        : product.size;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SafeNetworkImage(
                url: product.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.brand ?? product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$sizeLabel · ${product.condition}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            '${formatPrice(product.price)} GNF',
            style: AppTypography.style(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${formatPrice(product.priceWithShipping)} GNF ${t.includedSuffix}',
            style: AppTypography.style(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
