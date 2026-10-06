import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/checkout_api.dart';
import 'package:frip_cash/config/payment_simulation.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/checkout_address.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/screens/order_confirmation_screen.dart';
import 'package:frip_cash/screens/proximity_pickup_screen.dart';
import 'package:frip_cash/services/cart_store.dart';
import 'package:frip_cash/services/checkout_store.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/auth_text_field.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class OrangeMoneyPaymentScreen extends StatefulWidget {
  const OrangeMoneyPaymentScreen({super.key});

  @override
  State<OrangeMoneyPaymentScreen> createState() =>
      _OrangeMoneyPaymentScreenState();
}

class _OrangeMoneyPaymentScreenState extends State<OrangeMoneyPaymentScreen> {
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _statusHint;
  bool _cancelled = false;

  static const _orangeMoney = Color(0xFFFF7900);

  @override
  void initState() {
    super.initState();
    final address = CheckoutStore.instance.address;
    if (address != null) {
      _phoneController.text = address.phone;
    }
    _phoneController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cancelled = true;
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    final t = AppLocalizations.of(context)!;
    final address = CheckoutStore.instance.address;
    if (address == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.missingAddressRestartOrder),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (PaymentSimulation.enabled) {
      await _paySimulated(address: address);
      return;
    }

    setState(() {
      _loading = true;
      _statusHint = t.paymentConfirmationPrompt;
    });

    final checkout = CheckoutStore.instance;
    final omPhone = _phoneController.text.trim();
    final fulfillmentMode = checkout.fulfillmentMode;
    final deliveryFee = checkout.deliveryFeeOrZero;

    try {
      var quote = checkout.quote;
      quote ??= await checkout.refreshQuote();
      if (!mounted) return;

      if (!quote.canPay) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.removeOutOfStockToContinue),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final cartRevision = quote.cartRevision ?? CartStore.instance.revision;
      if (cartRevision == null || cartRevision.isEmpty) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.paymentCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final productIds =
          CartStore.instance.items.map((i) => i.product.id).toList();
      final sellerId = CartStore.instance.items.isNotEmpty
          ? CartStore.instance.items.first.product.sellerId
          : '';

      final intent = await CheckoutApi.instance.createPayment(
        cartRevision: cartRevision,
        fulfillmentMode: fulfillmentMode,
        address: address,
        orangeMoneyPhone: omPhone,
        quoteGrandTotalGnf: quote.grandTotalGnf,
      );

      if (!mounted) return;
      setState(() => _statusHint = t.paymentConfirmationPrompt);

      final finalIntent = await CheckoutApi.instance.pollPaymentStatus(
        intent.paymentIntentId,
        shouldCancel: () => _cancelled || !mounted,
      );

      if (!mounted) return;

      if (finalIntent.status != PaymentStatus.succeeded) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.paymentCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Clear cart only after succeeded (server clears too).
      CartStore.instance.clearLocal();
      checkout.clear();

      // Prefer server orders (multi-seller) over locally invented checkout order.
      await MockOrderService.instance.refreshBuyerOrders();
      MockOrder? order;
      for (final id in finalIntent.orderIds) {
        final refreshed = await MockOrderService.instance.refreshOrder(id);
        order ??= refreshed;
      }
      order ??= _buildSuccessOrder(
        intent: finalIntent,
        address: address,
        fulfillmentMode: fulfillmentMode,
        totalGnf: finalIntent.amountGnf,
        deliveryFeeGnf: deliveryFee,
        productIds: productIds,
        sellerId: sellerId,
      );
      if (!mounted) return;
      _navigateSuccess(order);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'TOTAL_CHANGED' || e.code == 'CART_REVISION_MISMATCH') {
        await checkout.refreshQuote();
        if (!mounted) return;
      }
      setState(() {
        _loading = false;
        _statusHint = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusHint = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _paySimulated({required CheckoutAddress address}) async {
    final t = AppLocalizations.of(context)!;
    final checkout = CheckoutStore.instance;
    final fulfillmentMode = checkout.fulfillmentMode;

    setState(() {
      _loading = true;
      _statusHint = 'Simulation du paiement…';
    });

    try {
      // Best-effort quote for accurate totals; simulation does not require PSP.
      try {
        final quote = checkout.quote ?? await checkout.refreshQuote();
        if (!quote.canPay) {
          if (!mounted) return;
          setState(() {
            _loading = false;
            _statusHint = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.removeOutOfStockToContinue),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      } catch (_) {
        // Continue with cart totals when quote is unavailable.
      }

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted || _cancelled) return;

      final cart = CartStore.instance;
      final items = List.of(cart.items);
      if (items.isEmpty) {
        setState(() {
          _loading = false;
          _statusHint = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.paymentCancelled),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final deliveryFee = checkout.deliveryFeeOrZero;
      final subtotal = items.fold<int>(
        0,
        (sum, i) => sum + i.product.price * i.quantity,
      );
      final totalGnf = checkout.grandTotalOrZero > 0
          ? checkout.grandTotalOrZero
          : subtotal + (fulfillmentMode.skipsCourier ? 0 : deliveryFee);

      final productIds = items.map((i) => i.product.id).toList();
      final sellerId = items.first.product.sellerId;
      final lines = [
        for (final item in items)
          OrderLineSnapshot(
            listingId: item.product.id,
            title: item.product.title,
            qty: item.quantity,
            unitDisplayPriceGnf: item.product.price,
            coverUrl: item.product.image,
            unitNetPriceGnf: item.product.netPrice,
            lineTotalDisplayGnf: item.product.price * item.quantity,
          ),
      ];

      final orderId = 'sim_${DateTime.now().millisecondsSinceEpoch}';
      final order = MockOrder(
        id: orderId,
        productIds: productIds,
        status: OrderStatus.paid,
        buyerId: MockSession.instance.user.id,
        buyerName: address.name,
        buyerZoneId: address.zoneId,
        sellerId: sellerId,
        sellerName: items.first.sellerName ?? items.first.product.sellerName,
        totalGnf: totalGnf,
        subtotalGnf: subtotal,
        buyerPhone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : address.phone,
        buyerAddress: address.fullAddressLine.isEmpty
            ? 'Adresse non renseignée'
            : address.fullAddressLine,
        buyerLandmark: address.landmark,
        deliveryFeeGnf: deliveryFee,
        fulfillmentMode: fulfillmentMode,
        pickupCode:
            fulfillmentMode.skipsCourier ? _fallbackPickupCode() : null,
        lines: lines,
      );

      MockOrderService.instance.rememberLocalPaidOrder(order);

      try {
        await cart.clear();
      } catch (_) {
        cart.clearLocal();
      }
      checkout.clear();

      if (!mounted) return;
      _navigateSuccess(order);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _statusHint = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  MockOrder _buildSuccessOrder({
    required PaymentIntent intent,
    required CheckoutAddress address,
    required FulfillmentMode fulfillmentMode,
    required int totalGnf,
    required int deliveryFeeGnf,
    required List<String> productIds,
    required String sellerId,
  }) {
    final pickupCode = intent.pickupCodes?.values.firstOrNull;
    final orderId = intent.orderIds.isNotEmpty
        ? intent.orderIds.first
        : 'ord_${DateTime.now().millisecondsSinceEpoch}';

    final order = MockOrder(
      id: orderId,
      productIds: productIds,
      status: OrderStatus.paid,
      buyerId: MockSession.instance.user.id,
      buyerName: address.name,
      buyerZoneId: address.zoneId,
      sellerId: sellerId,
      totalGnf: totalGnf,
      buyerPhone: address.phone,
      buyerAddress: address.fullAddressLine.isEmpty
          ? 'Adresse non renseignée'
          : address.fullAddressLine,
      buyerLandmark: address.landmark,
      deliveryFeeGnf: deliveryFeeGnf,
      fulfillmentMode: fulfillmentMode,
      pickupCode: fulfillmentMode.skipsCourier
          ? (pickupCode ?? _fallbackPickupCode())
          : pickupCode,
    );

    MockOrderService.instance.rememberLocalPaidOrder(order);
    return order;
  }

  String _fallbackPickupCode() {
    final n = DateTime.now().millisecondsSinceEpoch % 10000;
    return n.toString().padLeft(4, '0');
  }

  void _navigateSuccess(MockOrder? order) {
    if (!mounted) return;
    setState(() => _loading = false);
    final next = order != null &&
            order.isProximityFulfillment &&
            order.pickupCode != null
        ? ProximityPickupScreen(order: order)
        : const OrderConfirmationScreen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => next),
      (route) => route.isFirst,
    );
  }

  void _cancel() {
    final t = AppLocalizations.of(context)!;
    _cancelled = true;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.paymentCancelled),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final total = CheckoutStore.instance.grandTotalOrZero;
    final simulate = PaymentSimulation.enabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.orangeMoney,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (simulate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'Paiement simulé — Orange Money non configuré',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _orangeMoney.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.phone_android, size: 48, color: _orangeMoney),
                    const SizedBox(height: 12),
                    Text(
                      t.securePayment,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatPrice(total)} GNF',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _orangeMoney,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                t.orangeMoneyNumber,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [phoneNumberInputFormatter],
                enabled: !_loading,
                decoration: InputDecoration(
                  hintText: t.phoneNumberHint224,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _statusHint ??
                    (simulate
                        ? 'Confirmez pour simuler un paiement réussi.'
                        : t.paymentConfirmationPrompt),
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else ...[
                PillPrimaryButton(
                  label: simulate ? 'Simuler le paiement' : t.confirmPayment,
                  onPressed:
                      _phoneController.text.trim().isNotEmpty ? _pay : null,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _cancel,
                  child: Text(t.cancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
