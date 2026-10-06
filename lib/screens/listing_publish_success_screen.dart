import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/utils/listing_destination_labels.dart';
import 'package:frip_cash/utils/listing_routing.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class ListingPublishSuccessScreen extends StatefulWidget {
  const ListingPublishSuccessScreen({super.key, required this.product});

  final Product product;

  @override
  State<ListingPublishSuccessScreen> createState() =>
      _ListingPublishSuccessScreenState();
}

class _ListingPublishSuccessScreenState
    extends State<ListingPublishSuccessScreen> {
  bool _boost = false;
  bool _enhanceOpen = true;

  int get _listedCount {
    final user = MockSession.instance.user;
    if (!user.role.isSeller) return 1;
    return MockListingService.instance
        .listingsForSeller(user.sellerId)
        .length
        .clamp(1, 5);
  }

  void _done() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _copyListing() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => CreateListingScreen(product: widget.product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final count = _listedCount;
    final product = widget.product;
    final destination = listingDestinationForProduct(product);
    final sectionLabel = listingDestinationLabel(destination, t);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.niceItsListed,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _ListedProductPreview(product: product),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              t.listingPublishedInSection(sectionLabel),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.itemsListedProgress(count),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.listFiveItemsHint,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: AppColors.textPrimary
                                        .withValues(alpha: 0.65),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _ListingProgress(filled: count),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 28),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          t.boostYourListing,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.help_outline,
                                          size: 16,
                                          color: AppColors.textPrimary
                                              .withValues(alpha: 0.4),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t.boostListingBody,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.35,
                                        color: AppColors.textPrimary
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _boost,
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColors.primary,
                                onChanged: (v) => setState(() => _boost = v),
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          InkWell(
                            onTap: () =>
                                setState(() => _enhanceOpen = !_enhanceOpen),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.enhanceYourListing,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _enhanceOpen
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppColors.textPrimary,
                                ),
                              ],
                            ),
                          ),
                          if (_enhanceOpen) ...[
                            const SizedBox(height: 10),
                            Text(
                              t.enhanceListingBody,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              t.extraInfo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final tag in [
                              t.colours,
                              'Style',
                              'Material',
                              'Occasion',
                            ]) ...[
                              _EnhanceChip(label: '+ $tag'),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _copyListing,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            t.copyAListing,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _done,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(
                              color: AppColors.textPrimary,
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            t.done,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 12,
              right: 28,
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  t.listedBadge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact preview — buyers only see the total (commission already included).
class _ListedProductPreview extends StatelessWidget {
  const _ListedProductPreview({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: SafeNetworkImage(
                url: product.image,
                fit: BoxFit.cover,
                iconSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${formatPrice(product.price)} GNF',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingProgress extends StatelessWidget {
  const _ListingProgress({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++) ...[
          if (i > 1)
            Expanded(
              child: Container(
                height: 2,
                color: i <= filled
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
            ),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= filled ? AppColors.primary : Colors.white,
              border: Border.all(
                color: i <= filled ? AppColors.primary : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: i <= filled
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$i',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withValues(alpha: 0.45),
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

class _EnhanceChip extends StatelessWidget {
  const _EnhanceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
