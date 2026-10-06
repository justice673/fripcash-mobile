import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/home/home_showcase_section.dart';

class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          t.showcaseTitle,
          style: AppTypography.style(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        itemCount: showcaseSellerIds.length,
        separatorBuilder: (context, index) => const SizedBox(height: 28),
        itemBuilder: (context, index) {
          final sellerId = showcaseSellerIds[index];
          final seller = sellerById(sellerId);
          if (seller == null) return const SizedBox.shrink();

          return ShowcaseSellerBlock(
            seller: seller,
            products: showcaseProductsForSeller(seller.id),
            onSellerTap: () => openSellerProfile(context, seller.id),
            onProductTap: (product) => openProductDetail(context, product),
          );
        },
      ),
    );
  }
}
