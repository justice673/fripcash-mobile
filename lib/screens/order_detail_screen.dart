import 'package:flutter/material.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/api/orders_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_products.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/screens/rate_order_screen.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/order_status_localization.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/utils/seller_order_action_localization.dart';
import 'package:frip_cash/widgets/confirm_dialog.dart';
import 'package:frip_cash/widgets/dispute_dialog.dart';
import 'package:frip_cash/widgets/order_timeline.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/pickup_code_digits.dart';
import 'package:frip_cash/widgets/pickup_code_handoff_dialog.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderStatus? _lastStatus;
  String? _confirmFeedback;
  bool _disputeJustOpened = false;

  bool _actionBusy = false;

  @override
  void initState() {
    super.initState();
    _lastStatus = MockOrderService.instance.orderById(widget.orderId)?.status;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MockOrderService.instance.refreshOrder(widget.orderId);
    });
  }

  String _confirmMessage(AppLocalizations t, ConfirmReceiptMessage key) {
    return switch (key) {
      ConfirmReceiptMessage.notFound => t.confirmReceiptNotFound,
      ConfirmReceiptMessage.alreadyConfirmed => t.confirmReceiptAlreadyDone,
      ConfirmReceiptMessage.notReady => t.confirmReceiptNotReady,
      ConfirmReceiptMessage.released => t.confirmReceiptSuccess,
      ConfirmReceiptMessage.disputeLocked => t.confirmReceiptDisputeLocked,
    };
  }

  Future<void> _onConfirmReceipt(MockOrder order) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: t.confirmReceiptDialogTitle,
      description: t.confirmReceiptDialogBody,
      confirmLabel: t.confirmReceiptYes,
      cancelLabel: t.confirmReceiptNotYet,
    );
    if (!confirmed || !mounted) return;

    setState(() => _actionBusy = true);
    final result = await MockOrderService.instance.confirmReceipt(order.id);
    if (!mounted) return;
    setState(() {
      _actionBusy = false;
      _confirmFeedback = _confirmMessage(t, result.messageKey);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_confirmFeedback!),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            result.ok ? AppColors.sage : AppColors.textPrimary,
      ),
    );
  }

  Future<void> _onOpenDispute(MockOrder order) async {
    final t = AppLocalizations.of(context)!;
    final reason = await showOpenDisputeDialog(
      context: context,
      orderId: order.id,
    );
    if (reason == null || !mounted) return;

    setState(() => _actionBusy = true);
    final ok = await MockOrderService.instance.openDispute(
      order.id,
      reason: reason,
      openedVia: 'order_page',
    );
    if (!mounted) return;
    setState(() {
      _actionBusy = false;
      _disputeJustOpened = ok;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? t.disputeOpenedToast : t.disputeOpenFailed),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? const Color(0xFFB91C1C) : AppColors.textPrimary,
      ),
    );
  }

  Future<void> _onSellerAction(MockOrder order, SellerOrderAction action) async {
    final t = AppLocalizations.of(context)!;
    String? pickupCode;
    if (action.kind == SellerOrderActionKind.confirmHandoff) {
      pickupCode = await showPickupCodeHandoffDialog(context: context);
      if (pickupCode == null || !mounted) return;
    }

    setState(() => _actionBusy = true);
    final ok = await MockOrderService.instance.applySellerAction(
      order.id,
      pickupCode: pickupCode,
    );
    if (!mounted) return;
    setState(() => _actionBusy = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? action.localizedSuccessMessage(
                  t,
                  isProximity: order.isProximityFulfillment,
                )
              : (action.kind == SellerOrderActionKind.confirmHandoff
                  ? t.pickupCodeLabel
                  : t.orderNotFound),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStatusBanner(OrderStatus status) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('${t.orderStatusUpdated}: ${status.localizedLabel(t)}')),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _zoneLabel(String zoneId, AppLocalizations t) => switch (zoneId) {
        'zone_1' => 'Zone 1',
        'zone_2' => 'Zone 2',
        'other' => t.otherZone,
        _ => zoneId,
      };

  Future<void> _openRating(MockOrder order, String sellerName) async {
    final t = AppLocalizations.of(context)!;
    final rated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RateOrderScreen(
          orderId: order.id,
          sellerName: sellerName,
        ),
      ),
    );
    if (rated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.ratingSavedThanks),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockOrderService.instance,
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        final order = MockOrderService.instance.orderById(widget.orderId);
        if (order == null) {
          return Scaffold(
            body: Center(child: Text(t.orderNotFound)),
          );
        }

        if (_lastStatus != null && _lastStatus != order.status) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showStatusBanner(order.status);
          });
        }
        _lastStatus = order.status;

        final lines = displayLinesForOrder(order, ListingsRepository.instance.allCached);
        final seller = sellersById[order.sellerId] ?? defaultSeller;
        final sellerDisplayName = order.sellerName ?? seller.username;
        final user = MockSession.instance.user;
        final isSeller =
            hasSellerAccess && effectiveSellerId(user) == order.sellerId;
        final isCourier = user.role == UserRole.livreur;
        final isBuyer = order.buyerId == user.id ||
            MockOrderService.instance
                .ordersForBuyer(user)
                .any((o) => o.id == order.id);

        final sellerAction = isSeller
            ? MockOrderService.nextSellerAction(order)
            : null;
        final canMarkDelivered = isCourier &&
            order.status.index >= OrderStatus.readyForPickup.index &&
            order.status.index < OrderStatus.delivered.index;
        final canConfirmReceipt =
            isBuyer && MockOrderService.canConfirmReceipt(order);
        final paymentReleased = order.status.isPaymentReleased ||
            order.escrowState == EscrowState.released;
        final canRate = isBuyer && MockOrderService.canRateSeller(order);
        final canOpenDispute = isBuyer &&
            MockOrderService.canOpenDispute(order) &&
            !_disputeJustOpened;
        final isDisputed = order.status.isDisputed ||
            order.escrowState == EscrowState.locked;
        final isRefunded = order.status.isRefunded;

        final escrowLabel = isDisputed
            ? t.escrowDisputeLocked
            : isRefunded
                ? t.escrowRefundedBuyer
                : paymentReleased
                    ? t.escrowReleasedBuyer
                    : t.escrowHeldBuyer;

        final stepTotal = OrderStatus.timelineSteps.length;
        final stepLabel = isDisputed
            ? t.orderStatusDisputed
            : isRefunded
                ? t.orderStatusRefunded
                : '${t.stepLabel} ${order.stepIndex + 1} / $stepTotal';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              order.id,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status.localizedLabel(t),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stepLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: isDisputed
                              ? const Color(0xFFB91C1C)
                              : isRefunded
                                  ? Colors.blueGrey
                                  : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            escrowLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (order.pickupCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.rosePoudre,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.pickupCodeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      PickupCodeDigits(code: order.pickupCode!),
                      if (order.isProximityFulfillment) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.sellerPickupCodeHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (!isDisputed && !isRefunded) ...[
                const SizedBox(height: 24),
                Text(
                  t.orderTracking,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 14),
                OrderTimeline(currentStatus: order.status),
                if (canConfirmReceipt) ...[
                  const SizedBox(height: 8),
                  Text(
                    t.awaitingConfirmHint,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
              if (canConfirmReceipt ||
                  (paymentReleased && _confirmFeedback != null)) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.confirmReceiptTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (canConfirmReceipt) ...[
                        const SizedBox(height: 6),
                        Text(
                          t.confirmReceiptBody,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        PillPrimaryButton(
                          label: t.confirmReceiptButton,
                          onPressed: _actionBusy
                              ? null
                              : () => _onConfirmReceipt(order),
                        ),
                      ],
                      if (_confirmFeedback != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _confirmFeedback!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sage,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (canOpenDispute) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.disputeSomethingWrongTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.disputeSomethingWrongBody,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textPrimary.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => _onOpenDispute(order),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFB91C1C),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            t.disputeButton,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isDisputed) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.disputeOpenBanner,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                      if (order.disputeReason != null &&
                          order.disputeReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.disputeYourMessage(order.disputeReason!),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: const Color(0xFF7F1D1D).withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (isRefunded) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.refundResolvedBanner,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                      if (order.disputeReason != null &&
                          order.disputeReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.disputeYourMessage(order.disputeReason!),
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.blueGrey.shade700.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                t.items,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 10),
              for (final line in lines) ...[
                _OrderLineTile(line: line),
                const SizedBox(height: 8),
              ],
              const Divider(height: 28),
              _InfoRow(label: t.buyerRole, value: order.buyerName),
              _InfoRow(label: t.sellerRoleGeneric, value: sellerDisplayName),
              if (order.isProximityFulfillment)
                _InfoRow(
                  label: t.fulfillmentModeLabel,
                  value: order.fulfillmentMode == FulfillmentMode.pickup
                      ? t.fulfillmentPickup
                      : t.fulfillmentShopLocal,
                ),
              _InfoRow(
                label: t.deliveryZone,
                value: _zoneLabel(order.buyerZoneId, t),
              ),
              _InfoRow(label: t.phone, value: order.buyerPhone),
              if (!order.isProximityFulfillment &&
                  (order.courierName != null ||
                      order.status.index >=
                          OrderStatus.courierAssigned.index)) ...[
                _InfoRow(
                  label: t.courierRole,
                  value: order.courierName ?? t.awaitingAssignment,
                ),
              ],
              _InfoRow(
                label: t.total,
                value: '${formatPrice(order.totalGnf)} GNF',
                bold: true,
              ),
              if (sellerAction != null ||
                  canMarkDelivered ||
                  canRate ||
                  (isSeller && order.status.isDisputed)) ...[
                const SizedBox(height: 20),
                if (isSeller && order.status.isDisputed)
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
                  )
                else if (sellerAction != null)
                  PillPrimaryButton(
                    label: sellerAction.localizedLabel(
                      t,
                      isProximity: order.isProximityFulfillment,
                    ),
                    onPressed: _actionBusy
                        ? null
                        : () => _onSellerAction(order, sellerAction),
                  ),
                if (canMarkDelivered) ...[
                  if (sellerAction != null) const SizedBox(height: 10),
                  PillPrimaryButton(
                    label: t.parcelDelivered,
                    onPressed: _actionBusy
                        ? null
                        : () async {
                            setState(() => _actionBusy = true);
                            await MockOrderService.instance
                                .markDeliveredAsync(order.id);
                            if (mounted) setState(() => _actionBusy = false);
                          },
                  ),
                ],
                if (canRate) ...[
                  if (sellerAction != null || canMarkDelivered)
                    const SizedBox(height: 10),
                  PillPrimaryButton(
                    label: t.rateSeller,
                    onPressed: _actionBusy
                        ? null
                        : () => _openRating(order, sellerDisplayName),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderLineTile extends StatelessWidget {
  const _OrderLineTile({required this.line});

  final OrderLineSnapshot line;

  @override
  Widget build(BuildContext context) {
    final qtyLabel = line.qty > 1 ? ' ×${line.qty}' : '';
    return Row(
      children: [
        SafeNetworkImage(
          url: line.coverUrl ?? '',
          width: 48,
          height: 48,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '${line.title}$qtyLabel',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '${formatPrice(line.displayLineTotalGnf)} GNF',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
