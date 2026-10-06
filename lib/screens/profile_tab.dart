import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/badges_screen.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/my_account_screen.dart';
import 'package:frip_cash/screens/my_listings_screen.dart';
import 'package:frip_cash/screens/order_detail_screen.dart';
import 'package:frip_cash/screens/public_profile_screen.dart';
import 'package:frip_cash/screens/seller_dashboard_screen.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/utils/share_links.dart';
import 'package:frip_cash/widgets/profile_empty_illustrations.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/sell_options_sheet.dart';

/// Depop-style profile hub: Shop · Sold · Purchased · Likes.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.onFavoritesTap, this.onExplore});

  final VoidCallback? onFavoritesTap;
  final VoidCallback? onExplore;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    runAfterFrame(() {
      MockWalletService.instance.syncForUser(MockSession.instance.user);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _openSellSheet() {
    showSellOptionsSheet(context);
  }

  void _openBecomeSeller() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BecomeSellerScreen(),
      ),
    );
  }

  void _openMenu() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MyAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        MockSession.instance,
        MockWalletService.instance,
        MockListingService.instance,
        MockOrderService.instance,
        FavoritesStore.instance,
      ]),
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'fripcash',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _openSellSheet,
                                icon: const Icon(Icons.add, size: 28),
                                color: AppColors.textPrimary,
                              ),
                              IconButton(
                                onPressed: _openMenu,
                                icon: const Icon(Icons.menu, size: 26),
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor:
                      AppColors.textPrimary.withValues(alpha: 0.4),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  dividerColor: Colors.grey.shade200,
                  tabs: [
                    Tab(text: t.profileTabShop),
                    Tab(text: t.profileTabSold),
                    Tab(text: t.profileTabPurchased),
                    Tab(text: t.profileTabLikes),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _ShopPane(
                        onOpenSell: _openBecomeSeller,
                        onOpenDashboard: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SellerDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      const _SoldItemsPane(),
                      const _PurchasedPane(),
                      _LikesPane(onExplore: widget.onExplore),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Shop ───────────────────────────────────────────────────────────────────

class _ShopPane extends StatelessWidget {
  const _ShopPane({
    required this.onOpenSell,
    required this.onOpenDashboard,
  });

  final VoidCallback onOpenSell;
  final VoidCallback onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final name = user.shopName ?? user.name;
    final initials = name.trim().isEmpty
        ? 'FC'
        : name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((p) => p[0].toUpperCase())
            .join();
    final listings = hasSellerAccess
        ? MockListingService.instance.listingsForSeller(effectiveSellerId(user))
        : <Product>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const PublicProfileScreen(),
                        ),
                      );
                    },
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatChip(label: t.followersCount(0)),
                      const SizedBox(width: 12),
                      _StatChip(label: t.followingCount(0)),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.star_border,
                            size: 14,
                            color: AppColors.textPrimary.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            t.noReviews,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary
                                  .withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _OutlineAction(
                icon: Icons.bar_chart_rounded,
                label: t.shopStats,
                onTap: onOpenDashboard,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineAction(
                icon: Icons.verified_outlined,
                label: t.trackProgress,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BadgesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7F4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 52,
                  height: 52,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.local_shipping_outlined,
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
                      t.boostingFeesChanging,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.boostingFeesChangingBody,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.textPrimary.withValues(alpha: 0.65),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.learnMore,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Text(
              t.activeListingsCount(listings.length),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () async {
                final inStockOnly = await showModalBottomSheet<bool>(
                  context: context,
                  backgroundColor: AppColors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              t.listingFilterTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(t.showInStockOnly),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.pop(context, true),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(t.activeListingsCount(listings.length)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.pop(context, false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
                if (!context.mounted || inStockOnly == null) return;
                if (inStockOnly) {
                  final stocked =
                      listings.where((p) => p.inStock).toList(growable: false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.activeListingsCount(stocked.length)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: Icon(
                Icons.tune,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        if (!hasSellerAccess) ...[
          const SizedBox(height: 24),
          const Center(child: ProfileEmptyIllustrations.shop),
          const SizedBox(height: 12),
          Text(
            t.startSellingBuildShop,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onOpenSell,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            child: Text(t.sellAnItem),
          ),
        ] else if (listings.isEmpty) ...[
          const SizedBox(height: 24),
          const Center(child: ProfileEmptyIllustrations.shop),
          const SizedBox(height: 12),
          Text(
            t.activeListingsEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary.withValues(alpha: 0.65),
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = listings[index];
                return GestureDetector(
                  onTap: () => openProductDetail(context, product),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SafeNetworkImage(
                      url: product.image,
                      width: 110,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (!hasSellerAccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.bulkActionsHint),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyListingsScreen(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    t.bulkActions,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: const Color(0xFFF4F4F4),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    String? url;
                    try {
                      url = (await MeApi.instance.fetchSellerShare())
                          .publicShopUrl;
                    } catch (_) {
                      url = null;
                    }
                    if (!context.mounted) return;
                    await shareShop(
                      context,
                      sellerId: effectiveSellerId(user),
                      shopName: name,
                      publicUrl: url,
                    );
                  },
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.ios_share_outlined),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary.withValues(alpha: 0.55),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sold ───────────────────────────────────────────────────────────────────

enum _SoldFilter { all, toShip, inTransit, cancelled, completed }

class _SoldItemsPane extends StatefulWidget {
  const _SoldItemsPane();

  @override
  State<_SoldItemsPane> createState() => _SoldItemsPaneState();
}

class _SoldItemsPaneState extends State<_SoldItemsPane> {
  _SoldFilter _filter = _SoldFilter.toShip;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasSellerAccess) {
        MockOrderService.instance.refreshSellerOrders();
      }
    });
  }

  List<MockOrder> _filtered(List<MockOrder> all) {
    return all.where((o) {
      final s = o.status;
      return switch (_filter) {
        _SoldFilter.all => true,
        _SoldFilter.toShip =>
          s.index <= OrderStatus.readyForPickup.index && !s.isTerminalException,
        _SoldFilter.inTransit =>
          s.index >= OrderStatus.courierAssigned.index &&
              s.index < OrderStatus.delivered.index,
        _SoldFilter.cancelled => s.isTerminalException,
        _SoldFilter.completed =>
          s.index >= OrderStatus.delivered.index && !s.isTerminalException,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final sales = hasSellerAccess
        ? MockOrderService.instance.ordersForSeller(effectiveSellerId(user))
        : <MockOrder>[];
    final filtered = _filtered(sales);

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              for (final f in _SoldFilter.values) ...[
                _FilterPill(
                  label: switch (f) {
                    _SoldFilter.all => t.all,
                    _SoldFilter.toShip => t.filterToShip,
                    _SoldFilter.inTransit => t.filterInTransit,
                    _SoldFilter.cancelled => t.filterCancelled,
                    _SoldFilter.completed => t.completed,
                  },
                  selected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _HubEmpty(
                  illustration: ProfileEmptyIllustrations.toShip,
                  message: switch (_filter) {
                    _SoldFilter.toShip => t.emptySoldToShip,
                    _SoldFilter.inTransit => t.emptySoldInTransit,
                    _SoldFilter.cancelled => t.emptySoldCancelled,
                    _SoldFilter.completed => t.emptySoldCompleted,
                    _SoldFilter.all => t.emptySoldAll,
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _HubOrderCard(order: order);
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Purchased ──────────────────────────────────────────────────────────────

enum _PurchaseFilter { all, inProgress, cancelled, completed }

class _PurchasedPane extends StatefulWidget {
  const _PurchasedPane();

  @override
  State<_PurchasedPane> createState() => _PurchasedPaneState();
}

class _PurchasedPaneState extends State<_PurchasedPane> {
  _PurchaseFilter _filter = _PurchaseFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MockOrderService.instance.refreshBuyerOrders(
        filter: switch (_filter) {
          _PurchaseFilter.all => 'all',
          _PurchaseFilter.inProgress => 'inProgress',
          _PurchaseFilter.cancelled => 'cancelled',
          _PurchaseFilter.completed => 'completed',
        },
      );
    });
  }

  List<MockOrder> _filtered(List<MockOrder> all) {
    return all.where((o) {
      final s = o.status;
      return switch (_filter) {
        _PurchaseFilter.all => true,
        _PurchaseFilter.inProgress =>
          s.index < OrderStatus.delivered.index && !s.isTerminalException,
        _PurchaseFilter.cancelled => s.isTerminalException,
        _PurchaseFilter.completed =>
          s.index >= OrderStatus.delivered.index && !s.isTerminalException,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final purchases =
        MockOrderService.instance.ordersForBuyer(MockSession.instance.user);
    final filtered = _filtered(purchases);

    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            children: [
              for (final f in _PurchaseFilter.values) ...[
                _FilterPill(
                  label: switch (f) {
                    _PurchaseFilter.all => t.all,
                    _PurchaseFilter.inProgress => t.inProgress,
                    _PurchaseFilter.cancelled => t.filterCancelled,
                    _PurchaseFilter.completed => t.completed,
                  },
                  selected: _filter == f,
                  onTap: () {
                    setState(() => _filter = f);
                    MockOrderService.instance.refreshBuyerOrders(
                      filter: switch (f) {
                        _PurchaseFilter.all => 'all',
                        _PurchaseFilter.inProgress => 'inProgress',
                        _PurchaseFilter.cancelled => 'cancelled',
                        _PurchaseFilter.completed => 'completed',
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _HubEmpty(
                  illustration: ProfileEmptyIllustrations.purchased,
                  message: t.emptyPurchasedOrders,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _HubOrderCard(order: order);
                  },
                ),
        ),
      ],
    );
  }
}

// ─── Likes ──────────────────────────────────────────────────────────────────

class _LikesPane extends StatelessWidget {
  const _LikesPane({this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final favorites = FavoritesStore.instance.favorites;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
                color: const Color(0xFFF7F7F7),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              t.outfits,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          t.likedItems,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.refresh, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textPrimary.withValues(alpha: 0.75),
                    ),
                    children: [
                      TextSpan(text: t.likesInterestHint),
                      TextSpan(
                        text: t.seeMyLikes,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (favorites.isEmpty)
          _HubEmpty(
            illustration: ProfileEmptyIllustrations.likes,
            message: t.emptyLikesMessage,
            compact: true,
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favorites.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final product = favorites[index];
              return GestureDetector(
                onTap: () => openProductDetail(context, product),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SafeNetworkImage(
                          url: product.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${formatPrice(product.price)} GNF',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

// ─── Shared ─────────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HubEmpty extends StatelessWidget {
  const _HubEmpty({
    required this.illustration,
    required this.message,
    this.compact = false,
  });

  final Widget illustration;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28, vertical: compact ? 8 : 0),
      child: Column(
        mainAxisAlignment:
            compact ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          illustration,
          SizedBox(height: compact ? 12 : 18),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubOrderCard extends StatelessWidget {
  const _HubOrderCard({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lines = order.lines;
    String title;
    String? imageUrl;
    if (lines.isNotEmpty) {
      title = order.displayTitle;
      imageUrl = order.displayCoverUrl;
    } else {
      final products = order.productIds
          .map(productById)
          .whereType<Product>()
          .toList();
      title = products.isEmpty
          ? order.id
          : products.length == 1
              ? products.first.title
              : '${products.first.title} +${products.length - 1}';
      imageUrl = products.isEmpty ? null : products.first.image;
    }

    return Material(
      color: const Color(0xFFF7F7F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl == null
                    ? Container(
                        width: 64,
                        height: 64,
                        color: Colors.white,
                        child: const Icon(Icons.checkroom_outlined),
                      )
                    : SafeNetworkImage(
                        url: imageUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.status.localizedLabel(t),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${formatPrice(order.totalGnf)} GNF',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
