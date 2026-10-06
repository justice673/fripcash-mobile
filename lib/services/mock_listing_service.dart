import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/listings_repository.dart';

/// Seller inventory mutations via Nest — no mockProducts seed / fallback.
class MockListingService extends ChangeNotifier {
  MockListingService._() {
    ListingsRepository.instance.addListener(notifyListeners);
  }

  static final MockListingService instance = MockListingService._();

  final Map<String, int> _views = {};

  List<Product> listingsForSeller(String sellerId) {
    return ListingsRepository.instance.allCached
        .where((p) => p.sellerId == sellerId)
        .toList();
  }

  int viewsFor(String productId) => _views[productId] ?? 0;

  void updateListing(Product updated) {
    ListingsRepository.instance.upsert(updated);
    notifyListeners();
  }

  Future<void> updatePriceAsync(String productId, int netPrice) async {
    final product = await ListingsApi.instance.updatePrice(productId, netPrice);
    updateListing(product);
  }

  Future<void> adjustStockAsync(String productId, int delta) async {
    final product =
        await ListingsApi.instance.updateStock(productId, delta: delta);
    updateListing(product);
  }

  Future<void> addStockAsync(String productId, int amount) async {
    final product =
        await ListingsApi.instance.updateStock(productId, add: amount);
    updateListing(product);
  }

  Future<void> deleteListingAsync(String productId) async {
    try {
      await ListingsApi.instance.delete(productId);
      ListingsRepository.instance.remove(productId);
      _views.remove(productId);
      notifyListeners();
    } catch (e) {
      if (e is ApiException && e.code == 'LISTING_HAS_OPEN_ORDERS') {
        final hidden = await ListingsApi.instance.hide(productId);
        updateListing(hidden);
        return;
      }
      rethrow;
    }
  }

  Future<Product?> copyListingAsync(String productId) async {
    final draftId = await ListingsApi.instance.copy(productId);
    if (draftId.isEmpty) return null;
    final draft = await ListingsApi.instance.getById(draftId);
    updateListing(draft);
    return draft;
  }

  // Legacy sync wrappers — prefer *Async; kept so older call sites compile.
  void deleteListing(String productId) {
    deleteListingAsync(productId);
  }

  void updatePrice(String productId, int netPrice, {bool isProximity = false}) {
    updatePriceAsync(productId, netPrice);
  }

  void addStock(String productId, int amount) {
    addStockAsync(productId, amount);
  }

  void adjustStock(String productId, int delta) {
    adjustStockAsync(productId, delta);
  }
}
