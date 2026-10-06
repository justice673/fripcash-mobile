import 'package:frip_cash/utils/product_lookup.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/models/product.dart';

enum CatalogSortOption { recommended, priceLow, priceHigh, newest }

enum CatalogShopSort { bestRated, mostProducts, nameAz }

class CatalogListFilters {
  CatalogListFilters({
    this.sort = CatalogSortOption.recommended,
    this.condition,
    this.inStockOnly = false,
    int? minPrice,
    int? maxPrice,
  })  : minPrice = minPrice ?? catalogMinPrice,
        maxPrice = maxPrice ?? catalogMaxPrice;

  final CatalogSortOption sort;
  final String? condition;
  final bool inStockOnly;
  final int minPrice;
  final int maxPrice;

  static CatalogListFilters get none => CatalogListFilters();

  bool get hasActivePriceRange =>
      minPrice > catalogMinPrice || maxPrice < catalogMaxPrice;

  bool get hasActiveFilters =>
      condition != null ||
      inStockOnly ||
      hasActivePriceRange ||
      sort != CatalogSortOption.recommended;

  List<Product> applyFilters(List<Product> products) {
    var result = products;
    if (condition != null) {
      result = result.where((p) => p.condition == condition).toList();
    }
    if (inStockOnly) {
      result = result.where((p) => p.inStock).toList();
    }
    result = result
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();

    final sorted = List<Product>.from(result);
    switch (sort) {
      case CatalogSortOption.recommended:
        break;
      case CatalogSortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case CatalogSortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case CatalogSortOption.newest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
    }
    return sorted;
  }
}

class CatalogShopFilters {
  CatalogShopFilters({this.sort = CatalogShopSort.bestRated});

  final CatalogShopSort sort;

  static CatalogShopFilters get none => CatalogShopFilters();

  bool get hasActiveFilters => sort != CatalogShopSort.bestRated;

  List<MockShop> applyFilters(
    List<MockShop> shops, {
    required int Function(String sellerId) productCount,
  }) {
    final sorted = List<MockShop>.from(shops);
    switch (sort) {
      case CatalogShopSort.bestRated:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case CatalogShopSort.mostProducts:
        sorted.sort(
          (a, b) => productCount(b.sellerId)
              .compareTo(productCount(a.sellerId)),
        );
      case CatalogShopSort.nameAz:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }
    return sorted;
  }
}
