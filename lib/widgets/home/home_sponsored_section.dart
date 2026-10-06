import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/promotion.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/services/promotions_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

/// Featured promotions carousel — `GET /promotions?surface=HOME_APP`.
class HomeSponsoredSection extends StatefulWidget {
  const HomeSponsoredSection({
    super.key,
    this.topPadding = 20,
  });

  final double topPadding;

  @override
  State<HomeSponsoredSection> createState() => _HomeSponsoredSectionState();
}

class _HomeSponsoredSectionState extends State<HomeSponsoredSection> {
  final _pageController = PageController(viewportFraction: 0.92);
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PromotionsRepository.instance.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPromotion(FeaturedPromotion promo) {
    final type = promo.deepLinkType ??
        (promo.isShop
            ? FeaturedDeepLinkType.shop
            : FeaturedDeepLinkType.listing);
    final id = promo.navigationId;
    if (id == null || id.isEmpty) return;

    if (type == FeaturedDeepLinkType.listing || promo.isProduct) {
      final cached = PromotionsRepository.instance.productFor(promo);
      final product = cached ??
          Product(
            id: id,
            title: promo.title,
            price: promo.promoPriceGnf ?? 0,
            image: promo.imageUrl,
            size: '',
            categoryId: '',
            sellerId: promo.sellerProfileId ?? '',
            compareAtPrice: promo.compareAtPriceGnf,
            description: promo.description,
            images:
                promo.imageUrl.isNotEmpty ? <String>[promo.imageUrl] : null,
          );
      openProductDetail(context, product);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(sellerId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isTablet = AppBreakpoints.isTablet(context);
    final bannerHeight = isTablet ? 280.0 : 236.0;

    return ListenableBuilder(
      listenable: PromotionsRepository.instance,
      builder: (context, _) {
        final repo = PromotionsRepository.instance;
        final items = repo.items;

        if (repo.isLoading && items.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: widget.topPadding),
            child: SizedBox(
              height: bannerHeight * 0.45,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        }

        if (items.isEmpty) {
          if (repo.error != null && !repo.isLoaded) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16, widget.topPadding, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.catalogLoadError,
                      style: AppTypography.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        PromotionsRepository.instance.refresh(force: true),
                    child: Text(t.retryAction),
                  ),
                ],
              ),
            );
          }
          // Eligible window empty — quiet hide (no dummy cards).
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(top: widget.topPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.sponsoredSectionTitle,
                        style: AppTypography.style(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Text(
                      t.sponsoredBadge,
                      style: AppTypography.style(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: bannerHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, index) {
                    final promo = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _SponsoredPromoBanner(
                        promo: promo,
                        fallbackBadge: t.sponsoredBadge,
                        fallbackCta: t.shopNow,
                        height: bannerHeight,
                        isTablet: isTablet,
                        remaining: promo.endsAt == null
                            ? null
                            : repo.remainingUntil(promo.endsAt!),
                        onTap: () => _openPromotion(promo),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SponsoredPromoBanner extends StatelessWidget {
  const _SponsoredPromoBanner({
    required this.promo,
    required this.fallbackBadge,
    required this.fallbackCta,
    required this.height,
    required this.isTablet,
    required this.remaining,
    required this.onTap,
  });

  final FeaturedPromotion promo;
  final String fallbackBadge;
  final String fallbackCta;
  final double height;
  final bool isTablet;
  final Duration? remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final hasDiscount = promo.hasDiscount;
    final discountPercent = promo.effectiveDiscountPercent;
    final hasPrice = promo.promoPriceGnf != null;
    final rawBadge =
        (promo.badge != null && promo.badge!.trim().isNotEmpty)
            ? promo.badge!.trim()
            : null;
    // Nest may put "% off" in `badge` (e.g. "-14.29%") — skip that when we
    // already show the computed integer chip ("-14%").
    final badgeLooksLikeDiscount = rawBadge != null &&
        RegExp(r'-?\d+([.,]\d+)?\s*%').hasMatch(rawBadge);
    final badge = badgeLooksLikeDiscount
        ? null
        : (rawBadge ?? fallbackBadge);
    final cta =
        (promo.ctaLabel != null && promo.ctaLabel!.trim().isNotEmpty)
            ? promo.ctaLabel!.trim()
            : fallbackCta;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (promo.imageUrl.isNotEmpty)
                SafeNetworkImage(
                  url: promo.imageUrl,
                  fit: BoxFit.cover,
                )
              else
                ColoredBox(color: Colors.grey.shade300),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xCC000000),
                      Color(0x66000000),
                      Color(0x33000000),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0x99000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 24 : 16,
                  isTablet ? 18 : 14,
                  isTablet ? 24 : 16,
                  isTablet ? 18 : 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (badge != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              badge,
                              style: AppTypography.style(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (hasDiscount && discountPercent != null)
                            const SizedBox(width: 8),
                        ],
                        if (hasDiscount && discountPercent != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-$discountPercent%',
                              style: AppTypography.style(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        const Spacer(),
                        if (promo.endsAt != null)
                          _PromoCountdown(
                            endsAt: promo.endsAt!,
                            initialRemaining: remaining,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      promo.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.style(
                        fontSize: isTablet ? 26 : 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if ((promo.description ?? promo.subtitle) != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        promo.description ?? promo.subtitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.style(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (hasPrice) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${formatPrice(promo.promoPriceGnf!)} ${t.gnf}',
                            style: AppTypography.style(
                              fontSize: isTablet ? 20 : 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              '${formatPrice(promo.compareAtPriceGnf!)} ${t.gnf}',
                              style: TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.65),
                                decoration: TextDecoration.lineThrough,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              onTap: onTap,
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 16 : 14,
                                  vertical: isTablet ? 10 : 8,
                                ),
                                child: Text(
                                  cta,
                                  style: AppTypography.style(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16 : 14,
                                vertical: isTablet ? 10 : 8,
                              ),
                              child: Text(
                                cta,
                                style: AppTypography.style(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCountdown extends StatefulWidget {
  const _PromoCountdown({
    required this.endsAt,
    this.initialRemaining,
  });

  final DateTime endsAt;
  final Duration? initialRemaining;

  @override
  State<_PromoCountdown> createState() => _PromoCountdownState();
}

class _PromoCountdownState extends State<_PromoCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = widget.initialRemaining ??
        PromotionsRepository.instance.remainingUntil(widget.endsAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant _PromoCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endsAt != widget.endsAt ||
        oldWidget.initialRemaining != widget.initialRemaining) {
      _tick();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final next =
        PromotionsRepository.instance.remainingUntil(widget.endsAt);
    if (!mounted) return;
    setState(() => _remaining = next);
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    final clock = days > 0
        ? '${_two(days)}d ${_two(hours)}:${_two(minutes)}:${_two(seconds)}'
        : '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${t.flashSaleEndsIn} $clock',
            style: AppTypography.style(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
