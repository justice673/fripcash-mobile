import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/offer.dart';
import 'package:frip_cash/services/offers_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/empty_state_lottie.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_gate.dart';

class SellerOffersScreen extends StatefulWidget {
  const SellerOffersScreen({super.key});

  @override
  State<SellerOffersScreen> createState() => _SellerOffersScreenState();
}

class _SellerOffersScreenState extends State<SellerOffersScreen> {
  @override
  void initState() {
    super.initState();
    OffersRepository.instance.refreshSeller().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final repo = OffersRepository.instance;
    return SellerGate(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              t.receivedOffers,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            bottom: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: t.toHandle),
                Tab(text: t.accepted),
              ],
            ),
          ),
          body: ListenableBuilder(
            listenable: repo,
            builder: (context, _) {
              if (repo.loadingSeller &&
                  repo.pendingOffersForSeller('').isEmpty &&
                  repo.acceptedOffersForSeller('').isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final pending = repo.pendingOffersForSeller('');
              final accepted = repo.acceptedOffersForSeller('');

              return TabBarView(
                children: [
                  _OfferList(
                    offers: pending,
                    emptyLabel: t.noPendingOffers,
                    showActions: true,
                  ),
                  _OfferList(
                    offers: accepted,
                    emptyLabel: t.noAcceptedOffers,
                    showActions: false,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OfferList extends StatelessWidget {
  const _OfferList({
    required this.offers,
    required this.emptyLabel,
    required this.showActions,
  });

  final List<ProductOffer> offers;
  final String emptyLabel;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) {
      return EmptyStateView(
        illustration: const EmptyStateLottie(size: 168),
        title: emptyLabel,
      );
    }

    return RefreshIndicator(
      onRefresh: () => OffersRepository.instance.refreshSeller(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _IncomingOfferCard(
            offer: offers[index],
            showActions: showActions,
          );
        },
      ),
    );
  }
}

class _IncomingOfferCard extends StatelessWidget {
  const _IncomingOfferCard({
    required this.offer,
    required this.showActions,
  });

  final ProductOffer offer;
  final bool showActions;

  Future<void> _act(BuildContext context, {required bool accept}) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (accept) {
        await OffersRepository.instance.acceptOffer(offer.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.offerAcceptedBuyerNotified),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await OffersRepository.instance.refuseOffer(offer.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.offerRefused),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeNetworkImage(
                url: offer.productImage,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.productTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${t.offerLabel}: ${formatPrice(offer.offeredPrice)} GNF',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '${t.displayPricePrefix} : ${formatPrice(offer.listedPrice)} GNF',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      offer.createdAtLabel.localizedDateLabel(t),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!showActions)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    t.accepted,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _act(context, accept: false),
                    child: Text(t.refuse),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _act(context, accept: true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(t.accept),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
