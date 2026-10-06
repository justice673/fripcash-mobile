import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/cart_api.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/mock_session.dart';

class CartSellerGroup {
  const CartSellerGroup({required this.sellerId, required this.items});

  final String sellerId;
  final List<CartItem> items;
}

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
    this.lineId,
    this.shopKind,
    this.sellerName,
  });

  final Product product;
  int quantity;

  /// Server cart line id (for PATCH/DELETE).
  String? lineId;
  String? shopKind;
  String? sellerName;

  bool get isProximity {
    final kind = (shopKind ?? '').toLowerCase();
    if (kind.contains('proxim')) return true;
    if (product.isNeighborhoodShop) return true;
    if (product.destination == ListingDestination.quartierBoutiques) {
      return true;
    }
    return MockSession.instance.isProximitySeller(product.sellerId);
  }
}

/// Server-backed cart only — no local / mock cart.
class CartStore extends ChangeNotifier {
  CartStore._();

  static final CartStore instance = CartStore._();

  final List<CartItem> _items = [];
  String? _revision;
  String? _cartId;
  bool _syncing = false;
  List<CartValidationIssue> _validationIssues = const [];
  String? _lastError;

  List<CartItem> get items => List.unmodifiable(_items);

  String? get revision => _revision;
  String? get cartId => _cartId;
  bool get usingApi => true;
  bool get syncing => _syncing;
  String? get lastError => _lastError;
  List<CartValidationIssue> get validationIssues =>
      List.unmodifiable(_validationIssues);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Cart-sheet estimates only — checkout must use [CheckoutStore] quote.
  int get subtotal =>
      _items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  int get shippingTotal => _items.fold(
        0,
        (sum, item) => sum + item.product.shippingCost * item.quantity,
      );

  int get total => subtotal + shippingTotal;

  bool get hasUnavailableItems =>
      _items.any((item) => !item.product.inStock);

  List<CartSellerGroup> get groupedBySeller {
    final map = <String, List<CartItem>>{};
    for (final item in _items) {
      map.putIfAbsent(item.product.sellerId, () => []).add(item);
    }
    return map.entries
        .map((e) => CartSellerGroup(sellerId: e.key, items: e.value))
        .toList();
  }

  String? slaNoteForSeller(String sellerId) => null;

  bool get hasMultipleSellers => groupedBySeller.length > 1;

  bool contains(String productId) =>
      _items.any((item) => item.product.id == productId);

  void _applyApiCart(ApiCart cart) {
    _revision = cart.revision;
    _cartId = cart.id;
    _lastError = null;
    _items
      ..clear()
      ..addAll(
        cart.items.map(
          (line) => CartItem(
            product: line.toProduct(),
            quantity: line.quantity,
            lineId: line.id,
            shopKind: line.shopKind,
            sellerName: line.sellerName,
          ),
        ),
      );
  }

  Future<void> refresh() async {
    _syncing = true;
    _lastError = null;
    notifyListeners();
    try {
      final cart = await CartApi.instance.getCart();
      _applyApiCart(cart);
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  Future<void> add(
    Product product, {
    int quantity = 1,
    String? offerId,
    String? checkoutToken,
  }) async {
    final existing = _items
        .where((element) => element.product.id == product.id)
        .firstOrNull;
    final maxStock = product.stock > 0 ? product.stock : 1;
    if (existing != null) {
      // Already at max stock — treat as success so Buy just opens the cart.
      if (existing.quantity >= maxStock) {
        return;
      }
      await updateQuantity(product.id, existing.quantity + quantity);
      return;
    }

    try {
      final cart = await CartApi.instance.addItem(
        listingId: product.id,
        quantity: quantity,
        offerId: offerId,
        checkoutToken: checkoutToken,
      );
      _applyApiCart(cart);
      notifyListeners();
    } on ApiException catch (e) {
      // Race: line already at max on server.
      if (e.code == 'STOCK_EXCEEDED') {
        try {
          await refresh();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> remove(String productId) async {
    final item =
        _items.where((element) => element.product.id == productId).firstOrNull;
    if (item == null) return;
    if (item.lineId == null) {
      throw StateError('Cart line missing server id');
    }
    final cart = await CartApi.instance.removeItem(item.lineId!);
    _applyApiCart(cart);
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await remove(productId);
      return;
    }
    final item =
        _items.where((element) => element.product.id == productId).firstOrNull;
    if (item == null) return;
    if (item.lineId == null) {
      throw StateError('Cart line missing server id');
    }
    final cart = await CartApi.instance.updateItemQuantity(
      itemId: item.lineId!,
      quantity: quantity,
    );
    _applyApiCart(cart);
    notifyListeners();
  }

  /// Clears local cart only (e.g. after payment `succeeded` — server already cleared).
  void clearLocal() {
    _items.clear();
    _revision = null;
    _cartId = null;
    _validationIssues = const [];
    _lastError = null;
    notifyListeners();
  }

  Future<void> clear() async {
    final cart = await CartApi.instance.clearCart();
    _applyApiCart(cart);
    notifyListeners();
  }

  Future<CartValidationResult> validate() async {
    final result = await CartApi.instance.validate();
    _revision = result.revision;
    _validationIssues = result.issues;
    if (result.cart != null) {
      _applyApiCart(result.cart!);
    }
    notifyListeners();
    return result;
  }
}
