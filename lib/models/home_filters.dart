import 'package:frip_cash/utils/product_lookup.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';

enum HomeSortOption { recommended, priceLow, priceHigh, newest }

/// Quick seller pills under the home search bar.
enum HomeSellerPill { all, particuliers, boutiques, quartier, enseignes }

class HomeFilters {
  HomeFilters({
    this.sort = HomeSortOption.recommended,
    this.sellerType,
    this.sellerPill = HomeSellerPill.all,
    this.condition,
    this.inStockOnly = false,
    int? minPrice,
    int? maxPrice,
  })  : minPrice = minPrice ?? catalogMinPrice,
        maxPrice = maxPrice ?? catalogMaxPrice;

  final HomeSortOption sort;
  final SellerType? sellerType;
  final HomeSellerPill sellerPill;
  final String? condition;
  final bool inStockOnly;
  final int minPrice;
  final int maxPrice;

  static HomeFilters get none => HomeFilters();

  bool get hasActivePriceRange =>
      minPrice > catalogMinPrice || maxPrice < catalogMaxPrice;

  bool get hasActiveFilters =>
      sellerType != null ||
      sellerPill != HomeSellerPill.all ||
      condition != null ||
      inStockOnly ||
      hasActivePriceRange ||
      sort != HomeSortOption.recommended;

  HomeFilters copyWith({
    HomeSortOption? sort,
    SellerType? sellerType,
    bool clearSellerType = false,
    HomeSellerPill? sellerPill,
    String? condition,
    bool clearCondition = false,
    bool? inStockOnly,
    int? minPrice,
    int? maxPrice,
  }) {
    return HomeFilters(
      sort: sort ?? this.sort,
      sellerType: clearSellerType ? null : (sellerType ?? this.sellerType),
      sellerPill: sellerPill ?? this.sellerPill,
      condition: clearCondition ? null : (condition ?? this.condition),
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  /// Apply a home search-bar seller pill (keeps other filters).
  HomeFilters withSellerPill(HomeSellerPill pill) {
    return HomeFilters(
      sort: sort,
      sellerPill: pill,
      sellerType: switch (pill) {
        HomeSellerPill.all => null,
        HomeSellerPill.particuliers => SellerType.particulier,
        HomeSellerPill.boutiques => SellerType.boutique,
        HomeSellerPill.quartier => null,
        HomeSellerPill.enseignes => SellerType.enseigne,
      },
      condition: condition,
      inStockOnly: inStockOnly,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  /// Sync pills when the filter sheet sets a seller type.
  HomeFilters withSheetSellerType(SellerType? type) {
    final pill = switch (type) {
      null => HomeSellerPill.all,
      SellerType.particulier => HomeSellerPill.particuliers,
      SellerType.boutique => HomeSellerPill.boutiques,
      SellerType.enseigne => HomeSellerPill.enseignes,
    };
    return copyWith(
      sellerType: type,
      clearSellerType: type == null,
      sellerPill: pill,
    );
  }

  List<Product> applyFilters(List<Product> products) {
    var result = products;

    if (sellerPill == HomeSellerPill.quartier) {
      result = result.where((p) => p.isNeighborhoodShop).toList();
    } else if (sellerPill == HomeSellerPill.boutiques) {
      result = result
          .where(
            (p) =>
                p.sellerType == SellerType.boutique && !p.isNeighborhoodShop,
          )
          .toList();
    } else if (sellerPill == HomeSellerPill.particuliers) {
      result =
          result.where((p) => p.sellerType == SellerType.particulier).toList();
    } else if (sellerPill == HomeSellerPill.enseignes) {
      result =
          result.where((p) => p.sellerType == SellerType.enseigne).toList();
    } else if (sellerType != null) {
      result = result.where((p) => p.sellerType == sellerType).toList();
    }
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
      case HomeSortOption.recommended:
        break;
      case HomeSortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case HomeSortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case HomeSortOption.newest:
        sorted.sort((a, b) => b.id.compareTo(a.id));
    }
    return sorted;
  }
}
