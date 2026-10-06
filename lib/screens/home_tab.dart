import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/models/home_filters.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/notifications_screen.dart';
import 'package:frip_cash/screens/search_screen.dart';
import 'package:frip_cash/screens/wallet_screen.dart';
import 'package:frip_cash/services/catalog_repository.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_notification_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/promotions_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/home_universe_counts.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/home/home_categories_grid.dart';
import 'package:frip_cash/widgets/home/home_feed_grid.dart';
import 'package:frip_cash/widgets/home/home_filter_sheet.dart';
import 'package:frip_cash/widgets/home/home_hero_section.dart';
import 'package:frip_cash/widgets/home/home_recommended_section.dart';
import 'package:frip_cash/widgets/home/home_sponsored_section.dart';
import 'package:frip_cash/widgets/home/home_universe_sections.dart';
import 'package:frip_cash/tutorial/app_tutorial_keys.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, this.onFavoritesTap, this.onCartTap});

  final VoidCallback? onFavoritesTap;
  final VoidCallback? onCartTap;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });
    runAfterFrame(() {
      CatalogRepository.instance.ensureLoaded();
      ListingsRepository.instance.prefetchDiscovery();
      PromotionsRepository.instance.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _allProducts => ListingsRepository.instance.allCached;

  List<Product> get _searchResults {
    if (_searchQuery.isEmpty) return const [];
    return _allProducts
        .where((p) => productMatchesHomeSearch(p, _searchQuery))
        .toList();
  }

  List<Product> get _nouveautes {
    final best = CatalogRepository.instance.bestSellers;
    if (best.isNotEmpty) return best.take(8).toList();
    return List<Product>.from(_allProducts.take(8));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([
        ListingsRepository.instance,
        CatalogRepository.instance,
      ]),
      builder: (context, _) {
        final isSearching = _searchQuery.isNotEmpty;
        final searchResults = _searchResults;
        final error = ListingsRepository.instance.error ??
            CatalogRepository.instance.error;

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                searchController: _searchController,
                onFavoritesTap: widget.onFavoritesTap,
                onCartTap: widget.onCartTap,
                onFilterTap: () async {
                  await showHomeFilterSheet(
                    context,
                    initial: HomeFilters.none,
                  );
                },
              ),
            ),
            if (error != null && _allProducts.isEmpty && !isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    children: [
                      Text(
                        t.catalogLoadError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          CatalogRepository.instance.refresh();
                          ListingsRepository.instance.prefetchDiscovery();
                          PromotionsRepository.instance.refresh(force: true);
                        },
                        child: Text(t.retryAction),
                      ),
                    ],
                  ),
                ),
              ),
            if (isSearching && searchResults.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                  child: Text(
                    t.searchNoResults,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            if (!isSearching) ...[
              const SliverToBoxAdapter(child: HomeHeroSection()),
              const SliverToBoxAdapter(child: HomeCategoriesGrid()),
              const SliverToBoxAdapter(child: HomeUniverseSections()),
              const SliverToBoxAdapter(child: HomeSponsoredSection()),
              ...HomeRecommendedSection.buildSlivers(
                context: context,
                products: _nouveautes,
                title: t.homeNouveautesTitle,
                topPadding: 28,
                onProductTap: (product) => openProductDetail(context, product),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ] else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    t.searchResultsCount(searchResults.length),
                    style: AppTypography.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
              ...HomeFeedGrid.buildSlivers(
                context: context,
                products: searchResults,
                visibleCount: searchResults.length,
                isLoadingMore: false,
                topPadding: 8,
                onProductTap: (product) => openProductDetail(context, product),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.searchController,
    required this.onFilterTap,
    this.onFavoritesTap,
    this.onCartTap,
  });

  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onCartTap;

  String _displayName(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return 'Friend';
    final first = cleaned.split(RegExp(r'\s+')).first;
    if (first.isEmpty) return 'Friend';
    return first[0].toUpperCase() + first.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final name = _displayName(user.name);
    final zoneId = user.zoneId ?? 'zone_1';
    final quartier = homeQuartierFromAddress(user.address);
    final zone = zoneById(zoneId);
    final locationLabel = t.homeLocationLabel(
      zone?.name ?? 'Zone 1',
      quartier,
    );
    final topInset = MediaQuery.paddingOf(context).top;
    final isTablet = AppBreakpoints.isTablet(context);
    final contentWidth = AppBreakpoints.homeMaxWidth(context);
    final bubbleWidth = isTablet
        ? math.min(contentWidth * 0.72, MediaQuery.sizeOf(context).width * 0.48)
        : MediaQuery.sizeOf(context).width * 0.92;

    return ColoredBox(
      color: Colors.white,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -40,
            right: isTablet ? 12 : -48,
            child: IgnorePointer(
              child: SizedBox(
                width: bubbleWidth,
                height: isTablet ? 180 : 220,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CustomPaint(
                        size: Size(bubbleWidth, isTablet ? 180 : 220),
                        painter: const _HomeHeaderBlobPainter(
                          color: AppColors.blush,
                          variant: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, topInset + 10, 16, 18),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: AppTypography.style(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.homeHelloName(name),
                                style: AppTypography.style(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                locationLabel,
                                style: AppTypography.style(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _HeaderIconButton(
                          icon: Symbols.redeem_rounded,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const WalletScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _HeaderIconButton(
                          icon: AppIcons.favorite,
                          onTap: onFavoritesTap ?? () {},
                        ),
                        const SizedBox(width: 8),
                        ListenableBuilder(
                          listenable: MockNotificationService.instance,
                          builder: (context, _) {
                            final unread =
                                MockNotificationService.instance.unreadCount;
                            return _HeaderIconButton(
                              key: AppTutorialKeys.notifications,
                              icon: AppIcons.notifications,
                              showBadge: unread > 0,
                              badgeCount: unread > 0 ? unread : null,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const NotificationsScreen(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SearchBar(
                      key: AppTutorialKeys.searchBar,
                      controller: searchController,
                      onFilterTap: onFilterTap,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.homeSearchUniversesHint,
                      style: AppTypography.style(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: AppIcon(
                  icon,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
              if (showBadge && badgeCount != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (showBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
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

class _SearchBar extends StatefulWidget {
  const _SearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final VoidCallback onFilterTap;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final next = _focusNode.hasFocus;
      if (next == _focused) return;
      setState(() => _focused = next);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _focused
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : const Color(0xFFE8E8E8),
              width: _focused ? 1.5 : 1.2,
            ),
          ),
          padding: const EdgeInsets.only(left: 16, right: 6),
          child: Row(
            children: [
              AppIcon(
                AppIcons.search,
                size: 20,
                color: AppColors.textPrimary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  readOnly: true,
                  showCursor: false,
                  onTap: () async {
                    _focusNode.unfocus();
                    final initial = widget.controller.text.trim();
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SearchScreen(initialQuery: initial),
                      ),
                    );
                  },
                  textInputAction: TextInputAction.search,
                  style: AppTypography.style(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.homeSearchHint,
                    hintStyle: AppTypography.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary.withValues(alpha: 0.42),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  onPressed: widget.controller.clear,
                  icon: AppIcon(
                    AppIcons.close,
                    size: 18,
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeHeaderBlobPainter extends CustomPainter {
  const _HomeHeaderBlobPainter({
    required this.color,
    required this.variant,
  });

  final Color color;
  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: variant == 0 ? 0.55 : 0.92)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final path = Path();

    if (variant == 0) {
      path
        ..moveTo(w * 0.18, 0)
        ..cubicTo(w * 0.45, 0, w * 0.72, h * 0.05, w, h * 0.12)
        ..lineTo(w, h * 0.72)
        ..cubicTo(w * 0.88, h * 0.95, w * 0.55, h, w * 0.28, h * 0.78)
        ..cubicTo(w * 0.08, h * 0.58, w * 0.02, h * 0.28, w * 0.18, 0)
        ..close();
    } else {
      path
        ..moveTo(w * 0.22, 0)
        ..cubicTo(w * 0.55, 0, w * 0.85, h * 0.08, w, h * 0.22)
        ..lineTo(w, h * 0.78)
        ..cubicTo(w * 0.82, h * 0.98, w * 0.48, h, w * 0.22, h * 0.72)
        ..cubicTo(w * 0.02, h * 0.48, w * 0.0, h * 0.18, w * 0.22, 0)
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeHeaderBlobPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.variant != variant;
}
