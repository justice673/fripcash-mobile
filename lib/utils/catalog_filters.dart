import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/models/catalog_gender.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/services/listings_repository.dart';

List<Product> _catalogProducts(ListingDestination destination) {
  return ListingsRepository.instance.cachedFor(destination: destination);
}

List<Product> _withOptionalGender(
  List<Product> all,
  CatalogGender gender,
) {
  final filtered =
      all.where((p) => gender.matchesCategory(p.categoryId)).toList();
  if (filtered.isNotEmpty || all.isEmpty) return filtered;
  return all;
}

/// Boutique shops with new items, optionally filtered by gender tab.
List<MockShop> articlesNeufsShops(CatalogGender gender) {
  final products = _withOptionalGender(
    _catalogProducts(ListingDestination.articlesNeufs),
    gender,
  );
  final sellerIds = <String>{for (final product in products) product.sellerId};

  final shops = mockPopularShops
      .where(
        (shop) =>
            sellerIds.contains(shop.sellerId) && shop.quartier == null,
      )
      .toList();

  shops.sort((a, b) => b.rating.compareTo(a.rating));
  return shops;
}

int articlesNeufsCountForShop(String sellerId, CatalogGender gender) {
  return _withOptionalGender(
    _catalogProducts(ListingDestination.articlesNeufs),
    gender,
  ).where((p) => p.sellerId == sellerId).length;
}

int totalArticlesNeufsCount(CatalogGender gender) {
  return _withOptionalGender(
    _catalogProducts(ListingDestination.articlesNeufs),
    gender,
  ).length;
}

/// Second-hand listings from individual sellers.
List<Product> secondeMainProducts(CatalogGender gender) {
  final list = List<Product>.of(
    _withOptionalGender(
      _catalogProducts(ListingDestination.secondeMain),
      gender,
    ),
  );
  list.sort((a, b) => b.id.compareTo(a.id));
  return list;
}

int totalSecondeMainCount(CatalogGender gender) {
  return secondeMainProducts(gender).length;
}

List<Product> productsForDestination(ListingDestination destination) {
  return List.of(_catalogProducts(destination));
}

List<Product> discoveryProductsMatching(bool Function(Product) test) {
  return ListingsRepository.instance.allCached.where(test).toList();
}

List<Product> get discoveryAllProducts =>
    ListingsRepository.instance.allCached;
