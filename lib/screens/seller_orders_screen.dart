import 'package:flutter/material.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/screens/order_detail_screen.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/services/seller_dashboard_store.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/utils/seller_order_action_localization.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/pickup_code_digits.dart';
import 'package:frip_cash/widgets/pickup_code_handoff_dialog.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_gate.dart';

enum _SellerOrderFilter {
  all,
  needsAction,
  toPrepare,
  ready,
  delivered,
  disputed,
  refunded,
}

extension on _SellerOrderFilter {
  String label(AppLocalizations t) => switch (this) {
        _SellerOrderFilter.all => t.allPurchasesFilter,
        _SellerOrderFilter.needsAction => t.needsActionFilter,
        _SellerOrderFilter.toPrepare => t.toPrepare,
        _SellerOrderFilter.ready => t.ready,
        _SellerOrderFilter.delivered => t.delivered,
        _SellerOrderFilter.disputed => t.disputedFilter,
        _SellerOrderFilter.refunded => t.refundedFilter,
      };

  /// API filter query value (handoff seller filters).
  String? get apiFilter => switch (this) {
        _SellerOrderFilter.all => 'all',
        _SellerOrderFilter.needsAction => 'needsAction',
        _SellerOrderFilter.toPrepare => 'to_prepare',
        _SellerOrderFilter.ready => 'shipped',
        _SellerOrderFilter.delivered => 'sold',
        _SellerOrderFilter.disputed => 'disputed',
        _SellerOrderFilter.refunded => 'refunded',
      };

  bool matches(MockOrder order) {
    final index = order.status.index;
    return switch (this) {
      _SellerOrderFilter.all => true,
      _SellerOrderFilter.needsAction =>
        MockOrderService.orderNeedsSellerAction(order),
      _SellerOrderFilter.toPrepare =>
        !order.status.isTerminalException &&
            index < OrderStatus.readyForPickup.index,
      _SellerOrderFilter.ready =>
        !order.status.isTerminalException &&
            index >= OrderStatus.readyForPickup.index &&
            index < OrderStatus.delivered.index,
      _SellerOrderFilter.delivered =>
        !order.status.isTerminalException &&
            index >= OrderStatus.delivered.index &&
            !order.status.isPaymentReleased,
      _SellerOrderFilter.disputed => order.status.isDisputed,
      _SellerOrderFilter.refunded => order.status.isRefunded,
    };
  }
}

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  _SellerOrderFilter _filter = _SellerOrderFilter.needsAction;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MockOrderService.instance.refreshSellerOrders(
        filter: _filter.apiFilter,
      );
      SellerDashboardStore.instance.refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(_SellerOrderFilter filter) {
    setState(() => _filter = filter);
    MockOrderService.instance.refreshSellerOrders(
      filter: filter.apiFilter,
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  List<MockOrder> _filteredOrders(String sellerId, String query) {
    final q = query.trim().toLowerCase();
    return MockOrderService.instance.ordersForSeller(sellerId).where((order) {
      if (!_filter.matches(order)) return false;
      if (q.isEmpty) return true;
      final lines = displayLinesForOrder(order, ListingsRepository.instance.allCached);
      final title = lines.isNotEmpty ? lines.first.title : '';
      return order.id.toLowerCase().contains(q) ||
          title.toLowerCase().contains(q) ||
          buyerFirstName(order.buyerName).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return SellerGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          title: Text(
            t.sellerOrdersTitle,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            MockOrderService.instance,
            SellerDashboardStore.instance,
          ]),
          builder: (context, _) {
            final sellerId = effectiveSellerId();
            final allOrders =
                MockOrderService.instance.ordersForSeller(sellerId);
            final disputedCount =
                allOrders.where((o) => o.status.isDisputed).length;
            final query = _searchController.text;
            final orders = _filteredOrders(sellerId, query);
            final dash = SellerDashboardStore.instance.dashboard;
            final openCount = dash?.kpis.openEscrowOrderCount ??
                allOrders
                    .where((o) =>
                        !o.status.isTerminalException &&
                        !o.status.isPaymentReleased)
                    .length;
            final awaitingCount = allOrders
                .where(MockOrderService.orderAwaitingBuyerConfirmation)
                .length;
            final escrowGnf = dash?.wallet.pendingEscrowGnf ??
                allOrders
                    .where((o) =>
                        !o.status.isTerminalException &&
                        !o.status.isPaymentReleased)
                    .fold<int>(0, (sum, o) => sum + (o.sellerNetTotalGnf ?? 0));
            final completedCount = dash?.kpis.soldCount ??
                allOrders.where((o) => o.status.isPaymentReleased).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: t.searchOrdersHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                if (disputedCount > 0) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Material(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _onFilterChanged(
                          _SellerOrderFilter.disputed,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: Color(0xFFB91C1C),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.disputesBannerTitle(disputedCount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                    Text(
                                      t.disputesBannerBody,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(0xFF991B1B)
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                t.viewDisputes,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFB91C1C),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  height: 92,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _KpiChip(
                        label: t.openOrdersKpi,
                        value: '$openCount',
                      ),
                      _KpiChip(
                        label: t.awaitingConfirmationKpi,
                        value: '$awaitingCount',
                      ),
                      _KpiChip(
                        label: t.escrowOnHoldKpi,
                        value: '${formatPrice(escrowGnf)} GNF',
                        featured: true,
                      ),
                      _KpiChip(
                        label: t.completedOrdersKpi,
                        value: '$completedCount',
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Row(
                    children: _SellerOrderFilter.values.map((filter) {
                      final selected = _filter == filter;
                      final count = allOrders.where(filter.matches).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text('${filter.label(t)} ($count)'),
                          selected: selected,
                          onSelected: (_) => _onFilterChanged(filter),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? AppColors.primary
                                : Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: orders.isEmpty
                      ? Center(
                          child: Text(
                            t.noOrdersInCategory,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _SellerOrderCard(order: orders[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.label,
    required this.value,
    this.featured = false,
  });

  final String label;
  final String value;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: featured ? AppColors.primary : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: featured ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: featured ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: featured ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  const _SellerOrderCard({required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final lines = displayLinesForOrder(order, ListingsRepository.instance.allCached);
    final title = lines.isNotEmpty
        ? (lines.length == 1
            ? '${lines.first.title}${lines.first.qty > 1 ? ' ×${lines.first.qty}' : ''}'
            : '${lines.first.title} +${lines.length - 1}')
        : '${t.orderLabel} ${order.id}';
    final coverUrl = lines.isNotEmpty ? lines.first.coverUrl : null;
    final seller = sellersById[order.sellerId];
    final slaLabel =
        seller != null ? '${t.deliverWithin} ${seller.deliverySla}' : null;
    final action = MockOrderService.nextSellerAction(order);
    final isLocked = order.status.isDisputed;

    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (coverUrl != null && coverUrl.isNotEmpty)
                    SafeNetworkImage(
                      url: coverUrl,
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
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${t.clientLabel}: ${buyerFirstName(order.buyerName)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${order.id} · ${order.createdAtLabel.localizedDateLabel(t)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.status.localizedLabel(t),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.status.isDisputed
                                ? const Color(0xFFB91C1C)
                                : AppColors.primary,
                          ),
                        ),
                        if (order.pickupCode != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.rosePoudre,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  t.pickupCodeLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                PickupCodeDigits(
                                  code: order.pickupCode!,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${formatPrice(order.totalGnf)} GNF',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (slaLabel != null && !order.isProximityFulfillment) ...[
                const SizedBox(height: 10),
                _SlaChip(
                  label: slaLabel,
                  isOverdue: order.slaOverdue,
                ),
              ],
              if (isLocked) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    t.paymentLocked,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                      fontSize: 13,
                    ),
                  ),
                ),
              ] else if (action != null) ...[
                const SizedBox(height: 12),
                PillPrimaryButton(
                  label: action.localizedLabel(
                    t,
                    isProximity: order.isProximityFulfillment,
                  ),
                  height: 44,
                  onPressed: () async {
                    String? pickupCode;
                    if (action.kind == SellerOrderActionKind.confirmHandoff) {
                      pickupCode = await showPickupCodeHandoffDialog(
                        context: context,
                      );
                      if (pickupCode == null || !context.mounted) return;
                    }
                    final ok = await MockOrderService.instance.applySellerAction(
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SlaChip extends StatelessWidget {
  const _SlaChip({required this.label, required this.isOverdue});

  final String label;
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = isOverdue ? Colors.red.shade700 : AppColors.primary;
    final bg = isOverdue
        ? Colors.red.shade50
        : AppColors.primary.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.schedule,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isOverdue ? '$label — ${t.overdue}' : label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
