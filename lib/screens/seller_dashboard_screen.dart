import 'package:flutter/material.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/screens/excel_import_screen.dart';
import 'package:frip_cash/screens/my_account_screen.dart';
import 'package:frip_cash/screens/my_listings_screen.dart';
import 'package:frip_cash/screens/order_detail_screen.dart';
import 'package:frip_cash/screens/product_library_screen.dart';
import 'package:frip_cash/screens/seller_offers_screen.dart';
import 'package:frip_cash/screens/seller_orders_screen.dart';
import 'package:frip_cash/screens/settings_screen.dart';
import 'package:frip_cash/screens/wallet_screen.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';
import 'package:frip_cash/services/offers_store.dart';
import 'package:frip_cash/services/seller_dashboard_store.dart';
import 'package:frip_cash/services/seller_verification_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/utils/seller_order_action_localization.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/utils/share_links.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_gate.dart';
import 'package:frip_cash/widgets/pickup_code_digits.dart';
import 'package:frip_cash/widgets/pickup_code_handoff_dialog.dart';

/// Shared “Ma boutique” shell for particulier / boutique / enseigne.
class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key, this.forceBoutique = false});

  /// Kept for [ShopDashboardScreen] compatibility — chrome is unified now.
  final bool forceBoutique;

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

enum _BoutiqueTab { boutique, toPrepare, shipped, sold }

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  _BoutiqueTab _tab = _BoutiqueTab.toPrepare;

  String? _apiFilterFor(_BoutiqueTab tab) => switch (tab) {
        _BoutiqueTab.boutique => null,
        _BoutiqueTab.toPrepare => 'to_prepare',
        _BoutiqueTab.shipped => 'shipped',
        _BoutiqueTab.sold => 'sold',
      };

  void _selectTab(_BoutiqueTab tab) {
    setState(() => _tab = tab);
    final filter = _apiFilterFor(tab);
    if (filter != null) {
      MockOrderService.instance.refreshSellerOrders(filter: filter);
    }
  }

  @override
  void initState() {
    super.initState();
    runAfterFrame(() {
      MockWalletService.instance.syncForUser(MockSession.instance.user);
      MockOrderService.instance.refreshSellerOrders(filter: 'to_prepare');
      SellerDashboardStore.instance.refresh();
    });
  }

  Future<void> _withdraw() async {
    final t = AppLocalizations.of(context)!;
    final wallet = MockWalletService.instance;
    if (!wallet.canWithdraw) return;

    final amountController = TextEditingController(
      text: wallet.availableGnf.toString(),
    );
    final phoneController = TextEditingController(
      text: wallet.defaultPayoutMsisdn ?? MockSession.instance.user.phone,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.withdrawOnOrangeMoney),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t.availableBalance}: ${formatPrice(wallet.availableGnf)} GNF',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'GNF',
                  hintText: formatPrice(wallet.minWithdrawalGnf),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: t.orangeMoneyNumber,
                  hintText: t.phoneNumberHint224,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.confirm),
            ),
          ],
        );
      },
    );

    final amountText = amountController.text.trim();
    final phone = phoneController.text.trim();
    amountController.dispose();
    phoneController.dispose();

    if (confirmed != true || !mounted) return;

    final amount = int.tryParse(amountText) ?? 0;
    try {
      await wallet.withdrawToOrangeMoney(
        amount,
        orangeMoneyPhone: phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.withdrawalInitiatedSimulation),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<MockOrder> _ordersForTab(String sellerId, _BoutiqueTab tab) {
    final all = MockOrderService.instance.ordersForSeller(sellerId);
    // Prefer Nest filter semantics; keep client filter as display safety net.
    return all.where((o) {
      final i = o.status.index;
      return switch (tab) {
        _BoutiqueTab.boutique => false,
        _BoutiqueTab.toPrepare =>
          !o.status.isTerminalException &&
              i < OrderStatus.readyForPickup.index,
        _BoutiqueTab.shipped =>
          !o.status.isTerminalException &&
              i >= OrderStatus.readyForPickup.index &&
              i < OrderStatus.delivered.index,
        _BoutiqueTab.sold =>
          !o.status.isTerminalException &&
              (i >= OrderStatus.delivered.index || o.status.isPaymentReleased),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SellerGate(
      child: ListenableBuilder(
        listenable: Listenable.merge([
          MockSession.instance,
          MockOrderService.instance,
          OffersStore.instance,
          MockWalletService.instance,
          SellerVerificationService.instance,
          SellerDashboardStore.instance,
        ]),
        builder: (context, _) {
          final t = AppLocalizations.of(context)!;
          final user = MockSession.instance.user;
          final sellerId = effectiveSellerId(user);
          final dash = SellerDashboardStore.instance.dashboard;
          final kpis = dash?.kpis;
          final wallet = MockWalletService.instance;
          // Prefer Nest dashboard; empty shop → zeros (no client-invented KPIs).
          final available = dash?.wallet.availableGnf ??
              (wallet.usingApi ? wallet.availableGnf : 0);
          final escrow = dash?.wallet.pendingEscrowGnf ??
              (wallet.usingApi ? wallet.pendingEscrowGnf : 0);
          final escrowOrders = kpis?.openEscrowOrderCount ?? 0;
          final toPrepare = kpis?.toPrepareCount ?? 0;
          final listingsCount = kpis?.listingsActiveCount ?? 0;
          final offersCount = kpis?.offersPendingCount ?? 0;
          final todayLabel = kpis?.todaySalesLabel ?? '0 GNF';
          final shareUrl = dash?.share.publicShopUrl;
          final isProximity =
              user.isProximityShop || isProximitySellerProfile(user);
          final pendingVerification = isSellerVerificationPending ||
              (dash?.verificationStatus == 'PENDING');
          final isShop = widget.forceBoutique ||
              user.hasShop ||
              user.role == UserRole.boutique ||
              sellerProfileKind(user) == SellerProfileKind.boutiqueStandard ||
              sellerProfileKind(user) == SellerProfileKind.boutiqueEnseigne ||
              sellerProfileKind(user) == SellerProfileKind.boutiqueProximite;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              title: Text(
                t.myShop,
                style: AppTypography.display(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  tooltip: t.share,
                  onPressed: () {
                    final shopName =
                        dash?.shopName ?? user.shopName ?? user.name;
                    shareShop(
                      context,
                      sellerId: sellerId,
                      shopName: shopName,
                      publicUrl: shareUrl,
                    );
                  },
                  icon: const Icon(Icons.ios_share_outlined),
                ),
                IconButton(
                  tooltip: t.myAccountTitle,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyAccountScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_outline),
                ),
                IconButton(
                  tooltip: t.preferences,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: Color(0xFF5B8DEF),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pendingVerification)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.hourglass_top_outlined,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.sellerVerificationPendingTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.sellerVerificationPendingBody,
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.35,
                                      color: AppColors.textPrimary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: _BalanceCard(
                    availableGnf: available,
                    escrowGnf: escrow,
                    escrowOrderCount: escrowOrders,
                    onWithdraw: (dash != null
                            ? available >= (dash.wallet.minWithdrawalGnf)
                            : wallet.canWithdraw)
                        ? _withdraw
                        : null,
                    onOpenWallet: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WalletScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _BoutiqueTabs(
                  selected: _tab,
                  onChanged: _selectTab,
                ),
                Expanded(
                  child: switch (_tab) {
                    _BoutiqueTab.boutique => _BoutiqueHomePane(
                        sellerId: sellerId,
                        listingsCount: listingsCount,
                        toPrepare: toPrepare,
                        offers: offersCount,
                        todaySalesLabel: todayLabel,
                        isShop: isShop,
                        isProximity: isProximity,
                      ),
                    _BoutiqueTab.toPrepare => _OrdersPane(
                        orders: _ordersForTab(sellerId, _BoutiqueTab.toPrepare),
                        emptyLabel: t.noOrdersToPrepare,
                        showDeadlineBanner: toPrepare > 0,
                        deadlineCount: toPrepare,
                        showCourierTip: true,
                      ),
                    _BoutiqueTab.shipped => _OrdersPane(
                        orders: _ordersForTab(sellerId, _BoutiqueTab.shipped),
                        emptyLabel: t.noShippedOrders,
                        showDeadlineBanner: false,
                        deadlineCount: 0,
                        showCourierTip: false,
                      ),
                    _BoutiqueTab.sold => _OrdersPane(
                        orders: _ordersForTab(sellerId, _BoutiqueTab.sold),
                        emptyLabel: t.noSoldOrdersYet,
                        showDeadlineBanner: false,
                        deadlineCount: 0,
                        showCourierTip: false,
                      ),
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.availableGnf,
    required this.escrowGnf,
    required this.escrowOrderCount,
    required this.onWithdraw,
    required this.onOpenWallet,
  });

  final int availableGnf;
  final int escrowGnf;
  final int escrowOrderCount;
  final VoidCallback? onWithdraw;
  final VoidCallback onOpenWallet;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpenWallet,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.availableForWithdrawal,
                style: AppTypography.style(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${formatPrice(availableGnf)} GNF',
                style: AppTypography.display(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.escrowBarLabel(
                          formatPrice(escrowGnf),
                          escrowOrderCount,
                        ),
                        style: AppTypography.style(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onWithdraw,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        Colors.white.withValues(alpha: 0.55),
                    disabledForegroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    t.withdrawOnOrangeMoney,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

class _BoutiqueTabs extends StatelessWidget {
  const _BoutiqueTabs({
    required this.selected,
    required this.onChanged,
  });

  final _BoutiqueTab selected;
  final ValueChanged<_BoutiqueTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = <(_BoutiqueTab, String)>[
      (_BoutiqueTab.boutique, t.shopTabBoutique),
      (_BoutiqueTab.toPrepare, t.toPrepare),
      (_BoutiqueTab.shipped, t.shopTabShipped),
      (_BoutiqueTab.sold, t.profileTabSold),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final (tab, label) = items[index];
          final active = tab == selected;
          return InkWell(
            onTap: () => onChanged(tab),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.textPrimary.withValues(alpha: 0.45),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 3,
                  width: active ? 28 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BoutiqueHomePane extends StatelessWidget {
  const _BoutiqueHomePane({
    required this.sellerId,
    required this.listingsCount,
    required this.toPrepare,
    required this.offers,
    required this.todaySalesLabel,
    required this.isShop,
    required this.isProximity,
  });

  final String sellerId;
  final int listingsCount;
  final int toPrepare;
  final int offers;
  final String todaySalesLabel;
  final bool isShop;
  final bool isProximity;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: t.salesToday,
                value: todaySalesLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: t.myListings,
                value: '$listingsCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                label: t.toPrepare,
                value: '$toPrepare',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniStat(
                label: t.offersToHandle,
                value: '$offers',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          t.quickActions,
          style: AppTypography.style(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.add_circle_outline,
          title: t.newListing,
          onTap: () {
            if (isSellerVerificationPending) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.sellerVerificationPendingBody),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CreateListingScreen(),
              ),
            );
          },
        ),
        if (isProximity)
          _ActionTile(
            icon: Icons.menu_book_outlined,
            title: t.addFromLibrary,
            subtitle: t.addFromLibrarySubtitle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ProductLibraryScreen(),
                ),
              );
            },
          ),
        if (isShop)
          _ActionTile(
            icon: Icons.upload_file_outlined,
            title: t.importExcelCatalog,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ExcelImportScreen(),
                ),
              );
            },
          ),
        _ActionTile(
          icon: Icons.inventory_2_outlined,
          title: t.myListings,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const MyListingsScreen(),
              ),
            );
          },
        ),
        _ActionTile(
          icon: Icons.receipt_long_outlined,
          title: t.sellerOrdersTitle,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SellerOrdersScreen(),
              ),
            );
          },
        ),
        _ActionTile(
          icon: Icons.local_offer_outlined,
          title: t.receivedOffers,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SellerOffersScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.style(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.style(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.style(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTypography.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrdersPane extends StatelessWidget {
  const _OrdersPane({
    required this.orders,
    required this.emptyLabel,
    required this.showDeadlineBanner,
    required this.deadlineCount,
    required this.showCourierTip,
  });

  final List<MockOrder> orders;
  final String emptyLabel;
  final bool showDeadlineBanner;
  final int deadlineCount;
  final bool showCourierTip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyLabel,
            textAlign: TextAlign.center,
            style: AppTypography.style(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        if (showDeadlineBanner) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  color: Color(0xFFC62828),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.ordersToPrepareBefore(deadlineCount, '18 h'),
                    style: AppTypography.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        for (final order in orders) ...[
          _BoutiqueOrderCard(order: order),
          const SizedBox(height: 12),
        ],
        if (showCourierTip) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.primaryDark, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.delivery_dining_outlined,
                  color: AppColors.gold,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.courierTipTitle,
                        style: AppTypography.style(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.courierTipBody,
                        style: AppTypography.style(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BoutiqueOrderCard extends StatelessWidget {
  const _BoutiqueOrderCard({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final products = productsForOrder(order, ListingsRepository.instance.allCached);
    final title = products.isNotEmpty
        ? products.first.title
        : '${t.orderLabel} ${order.id}';
    final zone = order.buyerZoneId;
    final net = order.sellerNetTotalGnf ?? 0;
    final action = MockOrderService.nextSellerAction(order);
    final showPrepareTag =
        order.status.index < OrderStatus.readyForPickup.index &&
            !order.status.isTerminalException;

    return Material(
      color: Colors.white,
      elevation: 0.6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (products.isNotEmpty)
                    SafeNetworkImage(
                      url: products.first.image,
                      width: 64,
                      height: 64,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.display(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${buyerFirstName(order.buyerName)} · $zone',
                          style: AppTypography.style(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '#${order.id} · ${order.createdAtLabel.localizedDateLabel(t)}',
                          style: AppTypography.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showPrepareTag)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.toPrepare,
                        style: AppTypography.style(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              if (order.isProximityFulfillment &&
                  order.pickupCode != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: AppColors.rosePoudre,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.pickupCodeLabel,
                        style: AppTypography.style(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      PickupCodeDigits(code: order.pickupCode!, compact: true),
                      const SizedBox(height: 6),
                      Text(
                        t.sellerPickupCodeHint,
                        textAlign: TextAlign.center,
                        style: AppTypography.style(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.youReceive,
                          style: AppTypography.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${formatPrice(net)} GNF',
                          style: AppTypography.style(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (action != null)
                    FilledButton(
                      onPressed: () async {
                        String? pickupCode;
                        if (action.kind ==
                            SellerOrderActionKind.confirmHandoff) {
                          pickupCode = await showPickupCodeHandoffDialog(
                            context: context,
                          );
                          if (pickupCode == null || !context.mounted) return;
                        }
                        final ok =
                            await MockOrderService.instance.applySellerAction(
                          order.id,
                          pickupCode: pickupCode,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? action.localizedSuccessMessage(
                                      t,
                                      isProximity: order.isProximityFulfillment,
                                    )
                                  : t.pickupCodeLabel,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        action.localizedLabel(
                          t,
                          isProximity: order.isProximityFulfillment,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
