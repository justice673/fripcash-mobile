import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/checkout_api.dart';
import 'package:frip_cash/models/checkout_address.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/services/cart_store.dart';

/// Server-owned checkout quote only — no local fee matrix / mock totals.
class CheckoutStore extends ChangeNotifier {
  CheckoutStore._();

  static final CheckoutStore instance = CheckoutStore._();

  CheckoutAddress? _address;
  FulfillmentMode _fulfillmentMode = FulfillmentMode.courier;
  CheckoutQuote? _quote;
  bool _quoting = false;
  String? _quoteError;

  CheckoutAddress? get address => _address;
  FulfillmentMode get fulfillmentMode => _fulfillmentMode;
  CheckoutQuote? get quote => _quote;
  bool get quoting => _quoting;
  String? get quoteError => _quoteError;
  bool get usingApiQuote => _quote != null;

  void setAddress(CheckoutAddress address) {
    _address = address;
    _quote = null;
    notifyListeners();
  }

  void setFulfillmentMode(FulfillmentMode mode) {
    _fulfillmentMode = mode;
    _quote = null;
    notifyListeners();
  }

  void clear() {
    _address = null;
    _fulfillmentMode = FulfillmentMode.courier;
    _quote = null;
    _quoteError = null;
    notifyListeners();
  }

  bool get cartHasProximitySeller =>
      CartStore.instance.items.any((item) => item.isProximity);

  bool get cartHasCourierSeller =>
      CartStore.instance.items.any((item) => !item.isProximity);

  bool get hasMixedProximityCourierCart =>
      cartHasProximitySeller && cartHasCourierSeller;

  bool get isProximityCheckout =>
      cartHasProximitySeller && !cartHasCourierSeller;

  /// Requires a successful [refreshQuote] — never invent fees.
  int get deliveryFeeTotal {
    final q = _quote;
    if (q == null) {
      throw StateError('Checkout quote required before reading delivery fee');
    }
    return q.deliveryFeeGnf;
  }

  int get subtotal {
    final q = _quote;
    if (q == null) {
      throw StateError('Checkout quote required before reading subtotal');
    }
    return q.subtotalGnf;
  }

  int get grandTotal {
    final q = _quote;
    if (q == null) {
      throw StateError('Checkout quote required before reading grand total');
    }
    return q.grandTotalGnf;
  }

  /// Safe getters for UI before quote loads (show 0 / placeholders).
  int get deliveryFeeOrZero => _quote?.deliveryFeeGnf ?? 0;
  int get subtotalOrZero => _quote?.subtotalGnf ?? 0;
  int get grandTotalOrZero => _quote?.grandTotalGnf ?? 0;

  /// POST /checkout/quote — server owns totals.
  Future<CheckoutQuote> refreshQuote() async {
    final address = _address;
    if (address == null) {
      throw StateError('Checkout address required before quote');
    }

    _quoting = true;
    _quoteError = null;
    notifyListeners();

    try {
      var revision = CartStore.instance.revision;
      if (revision == null || revision.isEmpty) {
        await CartStore.instance.refresh();
        revision = CartStore.instance.revision;
      }
      if (revision == null || revision.isEmpty) {
        throw StateError('Cart revision required before quote');
      }

      final quote = await CheckoutApi.instance.quote(
        cartRevision: revision,
        fulfillmentMode: _fulfillmentMode,
        address: address,
      );
      _quote = quote;
      return quote;
    } catch (e) {
      _quote = null;
      _quoteError = e.toString();
      rethrow;
    } finally {
      _quoting = false;
      notifyListeners();
    }
  }
}
