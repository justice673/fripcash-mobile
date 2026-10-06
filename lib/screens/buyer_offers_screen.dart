import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/offer.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/offers_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/offer_status_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/product_lookup.dart';
import 'package:frip_cash/widgets/empty_state_lottie.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';

class BuyerOffersScreen extends StatefulWidget {
  const BuyerOffersScreen({super.key});

  @override
  State<BuyerOffersScreen> createState() => _BuyerOffersScreenState();
}

class _BuyerOffersScreenState extends State<BuyerOffersScreen> {
  @override
  void initState() {
    super.initState();
    OffersRepository.instance.refreshMine().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repo = OffersRepository.instance;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.myOffers,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: repo,
        builder: (context, _) {
          if (repo.loadingMine && repo.offers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final offers = repo.offers;
          if (offers.isEmpty) {
            return EmptyStateView(
              illustration: const EmptyStateLottie(size: 168),
              title: t.noOffersYet,
              subtitle: t.noOffersSubtitle,
              actionLabel: t.discoverItemsAction,
              onAction: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => repo.refreshMine(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _OfferCard(offer: offers[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final ProductOffer offer;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final product = productById(offer.productId);

    final statusColor = switch (offer.status) {
      OfferStatus.pending => Colors.orange.shade800,
      OfferStatus.accepted || OfferStatus.consumed => AppColors.primary,
      OfferStatus.refused ||
      OfferStatus.cancelled ||
      OfferStatus.expired =>
        Colors.red.shade600,
    };

    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: product == null
            ? null
            : () => openProductDetail(context, product),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  offer.productImage,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey.shade200,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.productTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${t.sellerRoleGeneric} : ${offer.sellerName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.offerLabel} : ${formatPrice(offer.offeredPrice)} GNF · '
                      '${t.priceLabel} : ${formatPrice(offer.listedPrice)} GNF',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    offer.status.localizedLabel(t),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    offer.createdAtLabel.localizedDateLabel(t),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
