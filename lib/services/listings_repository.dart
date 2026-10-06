import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/api/platform_api.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/utils/listing_routing.dart';
import 'package:frip_cash/utils/safe_notify.dart';

/// Nest listings catalog only — no mockProducts fallback.
class ListingsRepository extends ChangeNotifier with SafeNotify {
  ListingsRepository._();

  static final ListingsRepository instance = ListingsRepository._();

  bool _loading = false;
  String? _error;
  final List<Product> _cache = [];

  bool get isLoading => _loading;
  String? get error => _error;
  bool get usingApi => true;

  List<Product> get allCached => List.unmodifiable(_cache);

  Product? productById(String id) {
    for (final product in _cache) {
      if (product.id == id) return product;
    }
    return null;
  }

  void _upsertSilent(Product product) {
    final i = _cache.indexWhere((x) => x.id == product.id);
    if (i < 0) {
      _cache.insert(0, product);
      return;
    }
    final existing = _cache[i];
    // Discover rows often only include media[0]/cover. Never wipe a
    // detail-hydrated full gallery with a thinner list payload.
    final existingGallery = existing.galleryImages;
    final incomingGallery = product.galleryImages;
    final keepImages = existingGallery.length > incomingGallery.length
        ? existing.images ?? existingGallery
        : product.images ?? incomingGallery;
    final keepCover = keepImages.isNotEmpty ? keepImages.first : product.image;
    _cache[i] = product.copyWith(
      image: keepCover,
      images: keepImages.isEmpty ? null : keepImages,
      sellerName: product.sellerName ?? existing.sellerName,
      sellerAvatarUrl: product.sellerAvatarUrl ?? existing.sellerAvatarUrl,
      sellerRating: product.sellerRating ?? existing.sellerRating,
      sellerReviewCount:
          product.sellerReviewCount ?? existing.sellerReviewCount,
    );
  }

  void upsert(Product product) {
    _upsertSilent(product);
    safeNotifyListeners();
  }

  void remove(String id) {
    _cache.removeWhere((p) => p.id == id);
    safeNotifyListeners();
  }

  List<Product> cachedFor({
    ListingDestination? destination,
    String? categoryId,
  }) {
    var list = List<Product>.of(_cache);
    if (destination != null) {
      list = list
          .where((p) => listingDestinationForProduct(p) == destination)
          .toList();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    return List.unmodifiable(list);
  }

  /// Loads listings. On failure stores [error] and returns `[]` (no throw),
  /// so fire-and-forget callers never surface uncaught promise errors.
  Future<List<Product>> fetch({
    ListingDestination? destination,
    String? categoryId,
    String? sellerId,
    bool force = false,
  }) async {
    _loading = true;
    _error = null;
    safeNotifyListeners();
    try {
      await PlatformApi.instance.fetchCommissionRates();
      final page = await ListingsApi.instance.discover(
        destination: listingDestinationToApi(destination),
        categoryId: categoryId,
        sellerId: sellerId,
      );
      if (destination == null && categoryId == null && sellerId == null) {
        _cache
          ..clear()
          ..addAll(page.items);
      } else {
        for (final p in page.items) {
          _upsertSilent(p);
        }
      }
      return List.unmodifiable(page.items);
    } catch (e) {
      _error = e.toString();
      return const [];
    } finally {
      _loading = false;
      safeNotifyListeners();
    }
  }

  Future<Product?> fetchById(String id, {bool force = false}) async {
    _loading = true;
    _error = null;
    safeNotifyListeners();
    try {
      final product = await ListingsApi.instance.getById(id);
      upsert(product);
      return product;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      safeNotifyListeners();
    }
  }

  Future<List<Product>> fetchMyListings({String? status}) async {
    final page = await ListingsApi.instance.myListings(status: status);
    for (final p in page.items) {
      _upsertSilent(p);
    }
    safeNotifyListeners();
    return page.items;
  }

  Future<void> prefetchDiscovery() async {
    await fetch();
  }
}
